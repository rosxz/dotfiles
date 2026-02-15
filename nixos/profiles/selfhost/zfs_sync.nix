{ self, config, pkgs, lib, ... }: {

  services.sanoid = {
    enable = true;
    interval = "minutely"; # Important: Runs often to catch exact hourly boundaries

    datasets = {
      # 1. Production Source
      "storage-pool" = {
        use_template = [ "production" ];
        recursive = true;
        process_children_only = false;
      };

      # 2. Exclusions
      # This prevents snapshots, but we also need to tell Syncoid to skip it (see below)
      # Needs to be datasets not directories!
      #"storage-pool/torrents/Games" = {
      #  use_template = [ "ignore" ];
      #};

      # 3. Backup Destination (On USB)
      # We define this here so Sanoid can PRUNE old backups on the USB drive.
      "backup-pool" = {
        use_template = [ "backup" ];
        recursive = true;
        # We don't want Sanoid to snapshot the backup drive, only prune it.
        # The 'backup' template handles this, but being explicit helps.
        process_children_only = false;
      };
    };

    templates = {
      production = {
        autosnap = true;
        autoprune = true;

        # Since Syncoid runs hourly, you need these!
        hourly = 36;
        daily = 30;
        monthly = 3;
      };

      backup = {
        autosnap = false; # Syncoid puts snapshots here, Sanoid just cleans up.
        autoprune = true;

        # Backup Retention (Keep more than production)
        hourly = 48;  # Keep 2 days of hourlies on backup
        daily = 90;   # Keep 3 months of dailies
        monthly = 12; # Keep a year of monthlies

        # Monitoring (Optional but good)
        # Warn if backups stop arriving
        daily_warn = 48;
        daily_crit = 72;
      };

      ignore = {
        autoprune = false;
        autosnap = false;
        monitor = false;
      };
    };
  };

  services.syncoid = {
    enable = true;
    interval = "hourly";
    # Ensure common args are applied
    commonArgs = [ "--no-sync-snap" ]; 

    commands = {
      "main-backup" = {
        source = "storage-pool";
        # I recommend syncing to a dataset, not the root, for cleanliness.
        target = "backup-pool";
        
        # recursive: Sync all child datasets
        # exclude: MUST match the Sanoid ignore, or Syncoid will fail trying to find snapshots for Games
        extraArgs = [ "--recursive" "--exclude=torrents/Games" ];
      };
    };
  };
}
