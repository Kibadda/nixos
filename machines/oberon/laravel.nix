{
  pkgs,
  php ? pkgs.php,
  name,
  repository,
  port,
  restrict-access,
  time,
  secrets,
  description,
  lib,
}:
let
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
      phpPackages.composer
    ];
    text = ''
      set -e

      if [ "$(whoami)" != "${name}" ]; then
        echo "This script must be run as the ${name} user"
        exit 1
      fi

      cd "${secrets.dir}"

      if [ ! -d ".git" ]; then
        echo "Cloning repository..."
        find . -maxdepth 1 -not -name '.' -not -name 'storage' -not -name 'bootstrap' -exec rm -rf {} \;
        git clone https://github.com/${repository} temp_clone
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
      composer config http-basic.composer.fluxui.dev "${secrets.flux.username}" "${secrets.flux.license}"
      composer install --no-dev --optimize-autoloader --no-interaction

      echo "Installing Node.js dependencies..."
      npm ci
      echo "Building assets..."
      npm run build

      if [ ! -f ".env" ]; then
        echo "Creating .env file..."
        cp .env.example .env || echo "No .env.example found, createing basic .env"
      fi

      if ! grep -q "APP_KEY=base64:" .env; then
        echo "Generating application key..."
        php artisan key:generate --no-interaction
      fi

      sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
      sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
      sed -i "s|APP_URL=.*|APP_URL=https://${secrets.domain}|" .env

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
  oberon = {
    nginx.${secrets.domain} = {
      restrict-access = restrict-access;
      port = port;
    };

    backup.${name} = {
      path = "${secrets.dir}/database/database.sqlite";
      time = time;
    };

    dashboard.Home = [
      {
        name = builtins.concatStringsSep " " (map lib.toSentenceCase (lib.splitString "-" name));
        icon = "si-laravel-#FF2D20";
        description = description;
        url = "https://${secrets.domain}";
      }
    ];
  };

  users = {
    users.${name} = {
      isSystemUser = true;
      group = name;
      home = secrets.dir;
      createHome = true;
    };

    users.${secrets.username}.extraGroups = [ name ];

    groups.${name} = { };
  };

  environment.systemPackages = [ php ];

  systemd = {
    timers."${name}-schedule" = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "minutely";
    };

    services = {
      "${name}-schedule" = {
        description = "${name} scheduler";
        after = [ "${name}.service" ];
        wants = [ "${name}.service" ];

        serviceConfig = {
          Type = "oneshot";
          User = name;
          Group = name;
          WorkingDirectory = secrets.dir;
          ExecStart = "${php}/bin/php artisan schedule:run";
        };
      };

      "${name}-queue" = {
        description = "${name} queue";
        after = [ "${name}.target" ];
        wants = [ "${name}.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = name;
          Group = name;
          WorkingDirectory = secrets.dir;
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
          WorkingDirectory = secrets.dir;
          ExecStart = "${deployScript}/bin/${name}-deploy";
        };
      };

      ${name} = {
        description = "${name} application";
        after = [
          "network.target"
          "${name}-deploy.service"
        ];
        wants = [ "${name}-deploy.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = name;
          Group = name;
          WorkingDirectory = secrets.dir;
          ExecStart = "${php}/bin/php artisan serve --host=127.0.0.1 --port=${toString port}";
          Restart = "always";
          RestartSec = "5";
        };

        preStart = ''
          if [ ! -f "${secrets.dir}/.env" ]; then
            echo "Application not deployed, running deployment..."
            systemctl start ${name}-deploy.service
          fi
        '';
      };
    };

    tmpfiles.rules = [
      "d ${secrets.dir} 0755 ${name} ${name} - - "
      "d ${secrets.dir}/storage 0755 ${name} ${name} - - "
      "d ${secrets.dir}/storage/logs 0755 ${name} ${name} - - "
      "d ${secrets.dir}/storage/framework 0755 ${name} ${name} - - "
      "d ${secrets.dir}/storage/framework/cache 0755 ${name} ${name} - - "
      "d ${secrets.dir}/storage/framework/sessions 0755 ${name} ${name} - - "
      "d ${secrets.dir}/storage/framework/views 0755 ${name} ${name} - - "
      "d ${secrets.dir}/bootstrap/cache 0755 ${name} ${name} - - "
    ];
  };
}
