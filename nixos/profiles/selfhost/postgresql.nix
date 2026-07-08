{ self, config, pkgs, ... }: {

  services.postgresql = {
    package = pkgs.postgresql_17;
    enable = true;
    # settings.password_encryption = "scram-sha-256";
    ensureDatabases = [ "invidious" "nextcloud" "dispatcharr" "firefly-iii" ];
    ensureUsers = [
      { name = "invidious"; ensureDBOwnership = true; }
      { name = "nextcloud"; ensureDBOwnership = true; }
      { name = "dispatcharr"; ensureDBOwnership = true; }
      { name = "firefly-iii"; ensureDBOwnership = true; }
    ];
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      # This line allows the socket to use passwords:
      local   dispatcharr     dispatcharr                             scram-sha-256
      
      # Existing rules
      local   all             all                                     peer
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';
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
      mkdir -p /storage-pool/personal/postgresql/
      cd /storage-pool/personal/postgresql/
      
      # 1. Capture all dump files sorted by modification time (newest first)
      # Using 'printf' ensures we handle filenames safely.
      files=($(ls -1t dump_*.sql 2>/dev/null))
      
      # 2. Check if we exceed 15 files
      if [ ''${#files[@]} -gt 15 ]; then
        # 3. Calculate how many files to remove (everything after index 14)
        # This keeps exactly the 15 newest files.
        files_to_remove=("''${files[@]:15}")
        rm -f "''${files_to_remove[@]}"
      fi

      ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/pg_dumpall -c -U postgres > /storage-pool/personal/postgresql/dump_`date +%d-%m-%Y`.sql
    '';
    serviceConfig = {
      Type = "oneshot";
      User= "root";
    };
  };
  services.redis.servers."dispatcharr" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };
}
