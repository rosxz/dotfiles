{ self, config, pkgs, lib, ... }: {

services.sanoid = {
  enable = true;
  datasets = {
    "storage-pool" = { # Production (Source)
      use_template = [ "production" ];
      recursive = true;
    };
    "storage-pool/Torrents/Games".use_template = [ "ignore" ];
    "backup-pool" = { # Backup (Destination)
      use_template = [ "backup" ];
      recursive = true;
    };
  };
  templates = {
    production = {
      autosnap = yes;
      autoprune = yes;
      daily = 6;
      monthly = 1;
    };
    backup = {
      autosnap = false;
      autoprune = true;
      # Retention
      daily = 30;
      monthly = 2;

      # Monitoring Thresholds
      # Daily (Unit: Hours)
      daily_warn = 48;   # Warn if no daily snapshot in 2 days
      daily_crit = 72;   # Critical if no daily snapshot in 3 days

      # Monthly (Unit: Days)
      monthly_warn = 35; # Warn if no monthly snapshot in 35 days
      monthly_crit = 45; # Critical if no monthly snapshot in 45 days
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
  commands = {
    "main-backup" = {
      source = "storage-pool";
      target = "backup-pool/storage-backup";
      # --no-sync-snap tells syncoid to use the snapshots Sanoid already made
      extraArgs = [ "--no-sync-snap" "--recursive" ];
    };
  };
};
}
