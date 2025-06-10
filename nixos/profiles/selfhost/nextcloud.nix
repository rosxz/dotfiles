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
      package = pkgs.nextcloud31; # Need to manually increment with every update
      hostName = domain;
      configureRedis = true;
      database.createLocally = true;

      https = true;
      autoUpdateApps.enable = true;

      appstoreEnable = false;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts notes tasks; #memories
      };

      # home = "/mnt/Storage/nextcloud";
      # datadir = "/mnt/Storage/nextcloud";
      # TODO: problem with permissions in mnt/external storage, quick fix was to make a symbolic link
      # to it instead from var lib

      settings = {
	overwrite_protocol = "https";
        default_phone_region = "PT";
	trusted_domains = [ "https://${domain}/" ];
        trusted_proxies = [ "100.83.228.83" ];
      };
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
	dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = "nextcloud";
        # dbpassFile = config.age.secrets.nextcloud-db-pass.path;
        adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
        adminuser = "admin";
      };
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  users.users.nextcloud = {
    extraGroups = [ "media" ];
  };
}
