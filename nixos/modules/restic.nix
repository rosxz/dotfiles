{ self, config, pkgs, lib, ... }:

{

age.secrets.restic-pass = {
  file = "${self}/nixos/secrets/restic-pass.age";
  # probably should add user and group here
};

services.restic.backups.STORAGE = {
  timerConfig = { OnCalendar = "monthly"; };
  repository = "/mnt/Backup/STORAGE";
  paths = [ "/mnt/Storage/Torrents" ];
  passwordFile = config.age.secrets.restic-pass.path;
  initialize = true;
  pruneOpts = [ "--keep-monthly 3" ];
  extraBackupArgs = [ "--compression=max" ];
  # backupPrepareCommand = (builtins.readFile ../utils/resticStartup.sh);
  # backupCleanupCommand = (builtins.readFile ../utils/resticPost.sh);
  backupPrepareCommand = ''
   #!/bin/sh
   ${pkgs.mount}/bin/mount /dev/disk/by-label/BACKUP /mnt/Backup
  '';
  # ${pkgs.transmission}/bin/transmission-remote -N /var/lib/secrets/transmission/.netrc -t all --stop
  # ${pkgs.killall}/bin/killall -s SIGSTOP qbittorrent-nox
  backupCleanupCommand = ''
   #!/bin/sh
   ${pkgs.umount}/bin/umount /mnt/Backup
  '';
  # ${pkgs.transmission}/bin/transmission-remote -N /var/lib/secrets/transmission/.netrc -t all --start
  # ${pkgs.killall}/bin/killall -s SIGCONT qbittorrent
};

}
