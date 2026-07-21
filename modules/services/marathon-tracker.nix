{
  secrets,
  ...
}:
{
  flake.nixosModules.marathon-tracker =
    {
      config,
      pkgs,
      ...
    }:
    let
      name = "marathon-tracker";
      appDir = "/mnt/${name}";
      php = pkgs.php;

      deployScript = pkgs.writeShellApplication {
        name = "${name}-deploy";
        runtimeInputs = with pkgs; [
          php
          bash
          coreutils
          findutils
          gnused
          gnugrep
          which
          nodejs
          python3
          gcc
          git
          php84Packages.composer
          openssh
        ];
        text = ''
          set -e

          if [ "$(whoami)" != "${name}" ]; then
            echo "This script must be run as the ${name} user"
            exit 1
          fi

          export GIT_SSH_COMMAND="ssh -i ${appDir}/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

          mkdir -p "${appDir}/.ssh"
          echo "${secrets.pi.marathon-tracker.ssh-key}" > "${appDir}/.ssh/id_ed25519"
          chmod 600 "${appDir}/.ssh/id_ed25519"

          cd "${appDir}"

          if [ ! -d ".git" ]; then
            echo "Cloning repository..."
            find . -maxdepth 1 -not -name '.' -not -name 'storage' -not -name 'bootstrap' -not -name '.ssh' -exec rm -rf {} \;
            git clone git@github.com:Kibadda/marathon.git temp_clone
            mv temp_clone/.git .
            mv temp_clone/* . 2>/dev/null || true
            mv temp_clone/.[^.]* . 2>/dev/null || true
            rm -rf temp_clone
            git reset --hard HEAD
            touch database/database.sqlite
          else
            echo "Maintenance mode on..."
            php artisan down
            echo "Updating repository..."
            git fetch origin
            git reset --hard origin/main
          fi

          echo "Installing PHP dependencies..."
          composer config http-basic.composer.fluxui.dev "${secrets.pi.marathon-tracker.flux-username}" "${secrets.pi.marathon-tracker.flux-license}"
          composer install --no-dev --optimize-autoloader --no-interaction

          echo "Installing Node.js dependencies..."
          npm ci
          echo "Building assets..."
          npm run build

          if [ ! -f ".env" ]; then
            echo "Creating .env file..."
            cp .env.example .env || echo "No .env.example found"
          fi

          if ! grep -q "APP_KEY=base64:" .env; then
            echo "Generating application key..."
            php artisan key:generate --no-interaction
          fi

          sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
          sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
          sed -i "s|APP_URL=.*|APP_URL=${config.kibadda.services.marathon-tracker.url}|" .env
          sed -i "s|AUTHELIA_BASE_URL=.*|AUTHELIA_BASE_URL=${config.kibadda.services.authelia.url}|" .env
          sed -i "s|AUTHELIA_CLIENT_ID=.*|AUTHELIA_CLIENT_ID=marathon-tracker|" .env
          sed -i "s|AUTHELIA_CLIENT_SECRET=.*|AUTHELIA_CLIENT_SECRET=${secrets.pi.authelia.oidc.marathon-tracker}|" .env

          echo "Optimizing Laravel..."
          php artisan config:cache --no-interaction
          php artisan route:cache --no-interaction
          php artisan view:cache --no-interaction

          echo "Linking public storage..."
          php artisan storage:link

          if grep -q "DB_CONNECTION=" .env && ! grep -q "DB_CONNECTION=$" .env; then
            echo "Running database migrations..."
            php artisan migrate --force --no-interaction || echo "Migration failed or not needed"
          fi

          echo "Maintenance mode off..."
          php artisan up

          echo "Deployment completed successfully!"
        '';
      };
    in
    {
      kibadda.services.${name} = {
        description = "Joggen";
        subdomain = "joggen";
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.${name}.url}/auth/callback"
            "http://localhost:8000/auth/callback"
          ];
          method = "post";
        };
        extra = ''
          root * ${appDir}/public
          php_fastcgi unix/${config.services.phpfpm.pools.${name}.socket}
          file_server
        '';
        backup.archive = [ "${appDir}/database/database.sqlite" ];
        icon = "${config.kibadda.services.${name}.url}/favicon.svg";
        section = "Apps";
      };

      users = {
        users.${name} = {
          isSystemUser = true;
          group = name;
          home = appDir;
        };

        groups.${name} = {
          members = [
            name
            config.services.caddy.user
          ];
        };
      };

      environment.systemPackages = [ php ];

      services.phpfpm.pools.${name} = {
        phpPackage = php;
        user = name;
        group = name;
        settings = {
          "listen.owner" = config.services.caddy.user;
          "listen.group" = config.services.caddy.group;
          "pm" = "dynamic";
          "pm.max_children" = 5;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 1;
          "pm.max_spare_servers" = 3;
        };
      };

      systemd = {
        timers."${name}-schedule" = {
          wantedBy = [ "timers.target" ];
          timerConfig.OnCalendar = "minutely";
        };

        services = {
          "${name}-schedule" = {
            description = "${name} scheduler";
            after = [ "phpfpm-${name}.service" ];
            wants = [ "phpfpm-${name}.service" ];

            serviceConfig = {
              Type = "oneshot";
              User = name;
              Group = name;
              WorkingDirectory = appDir;
              ExecStart = "${php}/bin/php artisan schedule:run";
            };
          };

          "${name}-queue" = {
            description = "${name} queue";
            after = [ "phpfpm-${name}.service" ];
            wants = [ "phpfpm-${name}.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              Type = "simple";
              User = name;
              Group = name;
              WorkingDirectory = appDir;
              ExecStart = "${php}/bin/php artisan queue:work";
              Restart = "always";
              RestartSec = "5";
            };
          };

          "${name}-deploy" = {
            description = "${name} deploy";
            after = [ "network.target" ];

            serviceConfig = {
              Type = "oneshot";
              User = name;
              Group = name;
              WorkingDirectory = appDir;
              ExecStart = "${deployScript}/bin/${name}-deploy";
            };
          };
        };

        tmpfiles.rules = [
          "d ${appDir} 0755 ${name} ${name} - -"
          "d ${appDir}/.ssh 0700 ${name} ${name} - -"
          "d ${appDir}/storage 0755 ${name} ${name} - -"
          "d ${appDir}/storage/logs 0755 ${name} ${name} - -"
          "d ${appDir}/storage/framework 0755 ${name} ${name} - -"
          "d ${appDir}/storage/framework/cache 0755 ${name} ${name} - -"
          "d ${appDir}/storage/framework/sessions 0755 ${name} ${name} - -"
          "d ${appDir}/storage/framework/views 0755 ${name} ${name} - -"
          "d ${appDir}/bootstrap/cache 0755 ${name} ${name} - -"
        ];
      };
    };
}
