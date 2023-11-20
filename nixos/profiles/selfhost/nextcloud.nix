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
      configureRedis = true;

      https = true;
      autoUpdateApps.enable = true;

      enableBrokenCiphersForSSE = false;

      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit memories calendar contacts mail notes tasks;
        unsplash = pkgs.fetchNextcloudApp rec {
	  url =
            "https://github.com/nextcloud/unsplash/releases/download/v2.2.1/unsplash.tar.gz";
          sha256 = "sha256-/fOkTIRAwMgtgqAykWI+ahB1uo6FlvUaDNKztCyBQfk=";
	};
	cookbook = pkgs.fetchNextcloudApp rec {
          url =
            "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
          sha256 = "sha256-XgBwUr26qW6wvqhrnhhhhcN4wkI+eXDHnNSm1HDbP6M=";
        };
	news = pkgs.fetchNextcloudApp rec {
          url =
            "https://github.com/nextcloud/news/releases/download/22.0.0/news.tar.gz";
          sha256 = "sha256-hhXPEITSbCiFs0o+TOsQnSasXBpjU9mA/OFsbzuaCPw=";
        };
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

  users.users.nextcloud = {
    extraGroups = [ "media" ];
  };

  # At a certain point add impermanence
  # (steal from carjorvaz)
}
