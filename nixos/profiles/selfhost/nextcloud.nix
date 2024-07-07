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
      package = pkgs.nextcloud29; # Need to manually increment with every update
      hostName = domain;
      configureRedis = true;

      https = true;
      autoUpdateApps.enable = true;

      # appstoreEnable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts mail notes tasks; #memories
	# tasks = pkgs.fetchNextcloudApp rec {
	#   url = "https://github.com/nextcloud/tasks/releases/download/v0.16.0/tasks.tar.gz";
	#   sha256 = "L68ughpLad4cr5utOPwefu2yoOgRvnJibqfKmarGXLw=";
	#   license = "agpl3";
	# };
        # fetchNextcloudApp borked
        #unsplash = pkgs.fetchNextcloudApp rec {
	      #  url =
        #    "https://github.com/nextcloud/unsplash/releases/download/v2.2.1/unsplash.tar.gz";
        #  sha256 = "sha256-/fOkTIRAwMgtgqAykWI+ahB1uo6FlvUaDNKztCyBQfk=";
	      #};
	      #cookbook = pkgs.fetchNextcloudApp rec {
        #  url =
        #    "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
        #  sha256 = "sha256-XgBwUr26qW6wvqhrnhhhhcN4wkI+eXDHnNSm1HDbP6M=";
        #};
	      #news = pkgs.fetchNextcloudApp rec {
        #  url =
        #    "https://github.com/nextcloud/news/releases/download/24.0.0/news.tar.gz";
        #  sha256 = "";
        #};
      };

      # home = "/mnt/Storage/nextcloud";
      datadir = "/mnt/Storage/nextcloud";

      settings = {
	overwrite_protocol = "https";
        default_phone_region = "PT";
	trusted_domains = [ "https://cloud.moniz.pt" ];
        trusted_proxies = [ "100.83.228.83" ];
      };
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
	dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = "nextcloud";
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
}
