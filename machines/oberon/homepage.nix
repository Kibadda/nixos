{
  meta,
  pkgs,
  ...
}:
let
  php = pkgs.php.buildEnv {
    extraConfig = "upload_max_filesize = 8M";
  };

  deployScript = pkgs.writeShellApplication {
    name = "homepage-deploy";
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
      phpPackages.composer
    ];
    text = # bash
      ''
        set -e

        # Ensure we're running as the homepage user
        if [ "$(whoami)" != "homepage" ]; then
          echo "This script must be run as the homepage user"
          exit 1
        fi

        cd ${meta.pi.homepage.dir}

        # Clone or update repository
        if [ ! -d ".git" ]; then
          echo "Cloning repository..."
          # Remove any existing files but preserve storage directories
          find . -maxdepth 1 -not -name '.' -not -name 'storage' -not -name 'bootstrap' -exec rm -rf {} \;
          git clone https://github.com/Kibadda/homepage.git temp_clone
          mv temp_clone/.git .
          mv temp_clone/* . 2>/dev/null || true
          mv temp_clone/.[^.]* . 2>/dev/null || true
          rm -rf temp_clone
          git reset --hard HEAD
        else
          echo "Maintenance mode on..."
          php artisan down

          echo "Updating repository..."
          git fetch origin
          git reset --hard origin/main
        fi

        # Install PHP dependencies
        echo "Installing PHP dependencies..."
        composer config http-basic.composer.fluxui.dev "${meta.pi.homepage.flux.username}" "${meta.pi.homepage.flux.license}"
        composer install --no-dev --optimize-autoloader --no-interaction

        # Install Node.js dependencies and build assets
        echo "Installing Node.js dependencies..."
        npm ci
        echo "Building assets..."
        npm run build

        # Generate app key if not exists
        if [ ! -f ".env" ]; then
          echo "Creating .env file..."
          cp .env.example .env || echo "No .env.example found, creating basic .env"
        fi

        # Generate app key if empty
        if ! grep -q "APP_KEY=base64:" .env; then
          echo "Generating application key..."
          php artisan key:generate --no-interaction
        fi

        # Set environment variables
        sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
        sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
        sed -i "s|APP_URL=.*|APP_URL=https://${meta.pi.homepage.domain}|" .env

        # Run Laravel optimization commands
        echo "Optimizing Laravel..."
        php artisan config:cache --no-interaction
        php artisan route:cache --no-interaction
        php artisan view:cache --no-interaction

        echo "Linking public storage..."
        php artisan storage:link

        # Run migrations if database is configured
        if grep -q "DB_CONNECTION=" .env && ! grep -q "DB_CONNECTION=$" .env; then
          echo "Running database migrations..."
          php artisan migrate --force --no-interaction || echo "Migration failed or not needed"
        fi

        echo "Maintenance mode off"
        php artisan up

        echo "Deployment completed successfully!"
      '';
  };
in
{
  oberon = {
    nginx."${meta.pi.homepage.domain}" = {
      restrict-access = true;
      port = 8080;
    };

    backup.homepage = {
      path = meta.pi.homepage.dir;
      time = "04:00";
    };
  };

  users = {
    users.homepage = {
      isSystemUser = true;
      group = "homepage";
      home = meta.pi.homepage.dir;
      createHome = true;
    };

    groups.homepage = { };
  };

  systemd = {
    timers = {
      homepage-schedule = {
        wantedBy = [ "timers.target" ];

        timerConfig.OnCalendar = "minutely";
      };
    };

    services = {
      homepage-schedule = {
        description = "Laravel Homepage Scheduler";
        after = [ "homepage.service" ];
        wants = [ "homepage.service" ];

        serviceConfig = {
          Type = "oneshot";
          User = "homepage";
          Group = "homepage";
          WorkingDirectory = meta.pi.homepage.dir;
          ExecStart = "${php}/bin/php artisan schedule:run";
        };
      };

      homepage-queue = {
        description = "Laravel Homepage Queue";
        after = [ "homepage.service" ];
        wants = [ "homepage.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = "homepage";
          Group = "homepage";
          WorkingDirectory = meta.pi.homepage.dir;
          ExecStart = "${php}/bin/php artisan queue:work";
          Restart = "always";
          RestartSec = "5";
        };
      };

      homepage-deploy = {
        description = "Deploy Laravel Homepage Application";
        after = [ "network.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = "homepage";
          Group = "homepage";
          WorkingDirectory = meta.pi.homepage.dir;
          ExecStart = "${deployScript}/bin/homepage-deploy";
        };
      };

      homepage = {
        description = "Laravel Homepage Application";
        after = [
          "network.target"
          "homepage-deploy.service"
        ];
        wants = [ "homepage-deploy.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = "homepage";
          Group = "homepage";
          WorkingDirectory = meta.pi.homepage.dir;
          ExecStart = "${php}/bin/php artisan serve --host=127.0.0.1 --port=8080";
          Restart = "always";
          RestartSec = "5";
        };

        preStart = ''
          if [ ! -f ${meta.pi.homepage.dir}/.env ]; then
            echo "Application not deployed, running deployment..."
            systemctl start homepage-deploy.service
          fi
        '';
      };
    };

    tmpfiles.rules = [
      "d ${meta.pi.homepage.dir} 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/storage 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/storage/logs 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/storage/framework 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/storage/framework/cache 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/storage/framework/sessions 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/storage/framework/views 0755 homepage homepage - -"
      "d ${meta.pi.homepage.dir}/bootstrap/cache 0755 homepage homepage - -"
    ];
  };
}
