{ self, config, lib, pkgs, ... }:

# Backup notes:
# - https://docs.nextcloud.com/server/latest/admin_manual/maintenance/backup.html
# - https://docs.nextcloud.com/server/latest/admin_manual/maintenance/restore.html
# - /var/lib/nextcloud must be owned by nextcloud (sudo chown -R nextcloud: /var/lib/nextcloud)
let domain = "cloud.moniz.pt";
in {

  age.secrets.nextcloud-db-pass = {
    file = "${self}/secrets/nextcloud-db-pass.age";
    owner = "nextcloud";
    group = "nextcloud";
  };

  age.secrets.nextcloud-admin-pass = {
    file = "${self}/secrets/nextcloud-admin-pass.age";
    owner = "nextcloud";
    group = "nextcloud";
  };

  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud25; # Need to manually increment with every update
      hostName = domain;

      https = true;
      autoUpdateApps.enable = true;

      enableBrokenCiphersForSSE = false;

      extraAppsEnable = true;
      extraApps = with pkgs.nextcloud25Packages.apps; {
        inherit calendar contacts mail news notes tasks;
      };

      config = {
        overwriteProtocol = "https";
        defaultPhoneRegion = "PT";

        trustedProxies = [ "100.83.228.83" ];

        dbtype = "pgsql";
        dbuser = "nextcloud_user";
        dbhost = "db";
        dbname = "nextcloud_db";
        dbpassFile = config.age.secrets.nextcloud-db-pass.path;

        adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
        adminuser = "admin";
      };
    };

  # At a certain point move everything away from docker i suppose
  # (steal from carjorvaz)
}
