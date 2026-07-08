{
  config,
  pkgs,
  profiles,
  ...
}: let
  appn = "firefly-iii";
  domain = "firefly.moniz.pt";

  # Firefly must be able to store state (storage and bootstrap/cache)
  dataDir = "/var/lib/${appn}";
  appKeyEnvPath = "${dataDir}/app_key.env";
  laravelEnv = {
    # https://github.com/laravel/framework/blob/38fa79eaa22b95446b92db222d89ec04a7ef10c7/src/Illuminate/Foundation/Application.php look for env vars ($_ENV and normalizeCachePath)
    LARAVEL_STORAGE_PATH = "${dataDir}/storage";
    APP_SERVICES_CACHE = "${dataDir}/cache/services.php";
    APP_PACKAGES_CACHE = "${dataDir}/cache/packages.php";
    APP_CONFIG_CACHE = "${dataDir}/cache/config.php";
    APP_ROUTES_CACHE = "${dataDir}/cache/routes-v7.php";
    APP_EVENTS_CACHE = "${dataDir}/cache/events.php";
  };

  fireflyEnv =
    laravelEnv
    // {
      APP_ENV = "production";
      SITE_OWNER = "robots@moniz.pt";
      DEFAULT_LOCALE = "pt_PT";
      TZ = config.time.timeZone;

      DB_CONNECTION = "pgsql";
      DB_HOST = "/run/postgresql"; # socket dir
      DB_PORT = "5432"; # postgres is weird with sockets
      DB_USERNAME = appn;
      DB_DATABASE = appn;
      # TODO: setup email
      APP_URL = "https://${domain}";
    };

  wrappedArtisan = pkgs.writeShellScriptBin "artisan-${appn}" ''
    #!/bin/sh
    if [ "$UID" == "0" ]; then
      exec ${pkgs.util-linux}/bin/runuser -u "${appn}" -- "$0" "$@"
    fi

    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: "export ${name}=${value}") fireflyEnv))}

    # load app key
    source '${appKeyEnvPath}'
    export APP_KEY

    exec ${pkgs.firefly-iii}/share/php/firefly-iii/artisan "$@"
  '';
in {
  imports = [ ];

  services.nginx.virtualHosts.${domain} = {
    root = "${pkgs.firefly-iii}/share/php/firefly-iii/public";
    useACMEHost = "moniz.pt";
    forceSSL = true;

    locations = {
      "/".tryFiles = "$uri @rewriteapp";
      "@rewriteapp".extraConfig = ''
        # rewrite all to index.php
        rewrite ^(.*)$ /index.php last;
      '';
      "~ \\.php$" = {
        extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:${config.services.phpfpm.pools.${appn}.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
          fastcgi_param HTTP_PROXY ""; # something something HTTPoxy
        '';
      };
    };
  };

  services.phpfpm.pools."${appn}" = {
    phpPackage = pkgs.php83;
    user = appn;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 8;
      "pm.max_requests" = 64;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 4;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpEnv =
      fireflyEnv
      // {
        APP_KEY = "$APP_KEY"; # load from phpfpm service env
      };
  };
  systemd.services."phpfpm-${appn}" = {
    requires = [
      "laravelsetup-${appn}.service"

      # require DB for PHP, to avoid weird cascading errors
      "postgresql.service"
    ];
    after = [
      "laravelsetup-${appn}.service"
    ];
    serviceConfig.EnvironmentFile = "${appKeyEnvPath}";
    restartTriggers = [config.systemd.services."laravelsetup-${appn}".script];
  };

  systemd.services."laravelsetup-${appn}" = {
    description = "Setup storage directories for a Laravel-based web application";
    # Only run when dataDir does not yet contain the mount target
    unitConfig.ConditionPathExists = "!${appKeyEnvPath}";
    serviceConfig = {
      Type = "oneshot";
      User = appn;
      Group = appn;
    };
    script = let
      setupScript = pkgs.writeShellScript "setup-laravel.sh" ''
        set -e

        # keep data private (including the app key which will be generated here)
        umask 0007

        # ensure storage dir matches Laravel's expectations and is writable
        ${pkgs.rsync}/bin/rsync --ignore-existing -r ${pkgs.firefly-iii}/share/php/firefly-iii/storage ${dataDir}/
        chmod -R u+w ${dataDir}/storage

        # ensure bootstrap/cache-equivalent directory exists (will be writable)
        mkdir -p ${dataDir}/cache

        # generate a new app key (but must set a dummy one, as Laravel demands one to exist for artisan to function)
        echo "APP_KEY=$(APP_KEY=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa '${wrappedArtisan}/bin/artisan-${appn}' --no-ansi key:generate --show)" > '${appKeyEnvPath}'
      '';
    in ''
      ${setupScript} || { rm '${appKeyEnvPath}'; exit 1; }
    '';
  };

  services.postgresql.ensureDatabases = [appn];
  services.postgresql.ensureUsers = [
    {
      name = appn;
      ensureDBOwnership = true;
    }
  ];

  users.users.${appn} = {
    isSystemUser = true;
    home = dataDir;
    createHome = true;
    group = appn;

    packages = [wrappedArtisan];
  };
  users.users.root.packages = [wrappedArtisan];
  users.groups.${appn} = {};

  systemd.services."${appn}-cron" = {
    description = "Firefly III cron";
    requires = ["nginx.service" "phpfpm-${appn}.service"];
    wantedBy = ["phpfpm-${appn}.service"];
    after = ["nginx.service" "phpfpm-${appn}.service" "postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = appn;
      Group = appn;
    };
    environment = fireflyEnv;
    script = ''
      ${wrappedArtisan}/bin/artisan-${appn} firefly-iii:cron
    '';
  };
  systemd.timers."${appn}-cron" = {
    unitConfig.Description = "Firefly III cron";
    timerConfig.OnCalendar = "daily";
    wantedBy = ["timers.target"];
  };

  # TODO: backup ${dataDir}/storage/upload (or just the whole dataDir) and DB
}
