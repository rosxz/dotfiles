{ self, config, pkgs, ... }: {

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "invidious_db" "firefly_db" "nextcloud_db_pg" ];
    ensureUsers = [
      {
        name = "invidious_db";
        ensureDBOwnership = true;
      }
      {
        name = "nextcloud_db_pg";
        ensureDBOwnership = true;
      }
      #{
	    #  name = "firefly";
      #  ensureDBOwnership = true;
      #}
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
