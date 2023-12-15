{ self, config, pkgs, ... }: {

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "invidious" "nextcloud" ];
    ensureUsers = [
      {
        name = "invidious";
        ensureDBOwnership = true;
	ensurePermissions."DATABASE invidious" = "ALL PRIVILEGES";
      }
      {
        name = "nextcloud";
        ensureDBOwnership = true;
	ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  systemd.timers."postgres-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
	    OnCalendar="monthly";
	    Persistent=true;
      Unit = "postgres-backup.service";
    };
  };

  systemd.services."postgres-backup" = {
    script = ''
	${pkgs.mount}/bin/mount /dev/disk/by-label/BACKUP /mnt/Backup
	${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/pg_dumpall -c -U postgres > /mnt/Backup/postgresql/dump_`date +%d-%m-%Y`.sql
	${pkgs.umount}/bin/umount /mnt/Backup
    '';
    serviceConfig = {
      Type = "oneshot";
      User= "root";
    };
  };
}
