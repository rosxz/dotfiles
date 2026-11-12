{ self, config, lib, pkgs, ... }:

let
  version = "0.33.0-20261111220959"; # update here
  domain = "dispatcharr.moniz.pt";
  commonEnv = {
    DISPATCHARR_ENV = "modular";
    POSTGRES_HOST = "/run/postgresql";
    POSTGRES_USER = "dispatcharr";
    POSTGRES_DB = "dispatcharr";
    REDIS_HOST = "127.0.0.1";
    REDIS_PORT = "6379";
    DISPATCHARR_LOG_LEVEL = "info";
    DJANGO_SETTINGS_MODULE = "dispatcharr.settings";
    PYTHONUNBUFFERED = "1";
    DISPATCHARR_WEB_HOST = "127.0.0.1"; 
    DISPATCHARR_PORT = "9191";
  };
in {
  age.secrets.dispatcharr-env = { file = "${self}/secrets/dispatcharr-env.age"; };

  virtualisation.oci-containers.containers = {
    dispatcharr = {
      image = "ghcr.io/dispatcharr/dispatcharr:${version}";
      autoStart = true;
      environment = commonEnv;
      ports = [ "9191:9191" ];
      volumes = [ "/var/lib/dispatcharr:/data" "/run/postgresql:/run/postgresql" ];
      extraOptions = [ "--network=host" "--env-file=${config.age.secrets.dispatcharr-env.path}" ];
    };
    # The Background Worker (Celery)
    dispatcharr-worker = {
      image = "ghcr.io/dispatcharr/dispatcharr:${version}";
      autoStart = true;
      environment = commonEnv;
      volumes = [ "/var/lib/dispatcharr:/data" "/run/postgresql:/run/postgresql" ];
      entrypoint = "/app/docker/entrypoint.celery.sh";
      extraOptions = [ "--network=host" "--env-file=${config.age.secrets.dispatcharr-env.path}" ];
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:9191";
    locations."/".extraConfig = ''
      proxy_buffering off;
    '';
    locations."/ws" = {
      proxyPass = "http://127.0.0.1:9191";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
      '';
    };
  };
}
