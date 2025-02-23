{ self, config, pkgs, lib, ... }: {

age.secrets.restic-pass = {
  file = "${self}/secrets/restic-pass.age";
};

services.restic.backups.STORAGE = {
  timerConfig = { OnCalendar = "weekly"; };
  repository = "/mnt/Backup/STORAGE";
  paths = [ "/mnt/Storage/Torrents" "/mnt/Storage/nextcloud" ];
  passwordFile = config.age.secrets.restic-pass.path;
  initialize = true;
  pruneOpts = [ "--keep-last 5" ];
  extraBackupArgs = [ "--compression=max" ];
  # backupPrepareCommand = '''';
  # ${pkgs.transmission}/bin/transmission-remote -N /var/lib/secrets/transmission/.netrc -t all --stop
  backupCleanupCommand = ''
   #!/bin/sh
   ${pkgs.umount}/bin/umount /mnt/Backup
  '';
  # ${pkgs.transmission}/bin/transmission-remote -N /var/lib/secrets/transmission/.netrc -t all --start
};

systemd.services."restic-backups-STORAGE" = {
  requires = [ "mnt-Backup.mount" ];
  after = [ "mnt-Backup.mount" ];
};

systemd.mounts = [
  {
    description = "Exec pre restic for mount backup disk";
    what = "/dev/disk/by-uuid/d72b8d0b-f0cc-4f5a-af25-aca197560c59";
    where = "/mnt/Backup";
    type = "ext4";
  }
];

}
