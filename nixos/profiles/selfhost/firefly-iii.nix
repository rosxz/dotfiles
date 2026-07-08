{
  self,
  config,
  ...
}: let
  fire_domain = "fire.moniz.pt";
  fire_di_domain = "firedi.moniz.pt";
in {

age.secrets.firefly-app-key = {
    owner = "firefly-iii";
    file = "${self}/secrets/firefly-app-key.age";
};

services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = fire_domain;
    settings = {
        APP_URL = "https://${fire_domain}";
        APP_KEY_FILE = config.age.secrets.firefly-app-key.path;
        DB_CONNECTION = "pgsql";
    };
    poolConfig."listen.owner" = config.services.nginx.user;
    poolConfig."php_admin_value[error_log]" = "stderr";
    poolConfig."php_admin_flag[log_errors]" = true;
    poolConfig."catch_workers_output" = true;
};

services.firefly-iii-data-importer = {
    enable = true;
    enableNginx = true;
    virtualHost = fire_di_domain;
    poolConfig."listen.owner" = config.services.nginx.user;
    poolConfig."php_admin_value[error_log]" = "stderr";
    poolConfig."php_admin_flag[log_errors]" = true;
    poolConfig."catch_workers_output" = true;
    settings = {
        APP_URL = "https://${fire_di_domain}";
        APP_ENV = "local";
        LOG_CHANNEL = "syslog";
    };
};

services.nginx.virtualHosts.${fire_domain} = {
  useACMEHost = "moniz.pt";
  forceSSL = true;
};
services.nginx.virtualHosts.${fire_di_domain} = {
  useACMEHost = "moniz.pt";
  forceSSL = true;
};

}