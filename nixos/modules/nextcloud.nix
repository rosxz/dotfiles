{ self, config, lib, pkgs, ... }:

# Backup notes:
# - https://docs.nextcloud.com/server/latest/admin_manual/maintenance/backup.html
# - https://docs.nextcloud.com/server/latest/admin_manual/maintenance/restore.html
# - /var/lib/nextcloud must be owned by nextcloud (sudo chown -R nextcloud: /var/lib/nextcloud)
let domain = "cloud.moniz.pt";
in {

  age.secrets.nextcloud-db-pass = {
    file = "${self}/nixos/secrets/nextcloud-db-pass.age";
    owner = "nextcloud";
    group = "nextcloud";
  };

  age.secrets.nextcloud-admin-pass = {
    file = "${self}/nixos/secrets/nextcloud-admin-pass.age";
    owner = "nextcloud";
    group = "nextcloud";
  };

  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud27; # Need to manually increment with every update
      hostName = domain;

      https = true;
      autoUpdateApps.enable = true;

      enableBrokenCiphersForSSE = false;

      extraAppsEnable = true;
      extraApps = with pkgs.nextcloud25Packages.apps; {
        inherit calendar contacts mail news notes tasks unsplash;
      };

      # home = "/mnt/Storage/nextcloud";
      datadir = "/mnt/Storage/nextcloud";

      config = {
        overwriteProtocol = "https";
        defaultPhoneRegion = "PT";

        trustedProxies = [ "100.83.228.83" ];

        dbtype = "pgsql";
        dbuser = "nextcloud";
	dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = "nextcloud_db_pg";
        dbpassFile = config.age.secrets.nextcloud-db-pass.path;

        adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
        adminuser = "admin";
      };
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  # At a certain point add impermanence
  # (steal from carjorvaz)
}
