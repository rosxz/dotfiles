{ self, config, pkgs, ... }: {
    
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "invidious_db" "firefly_db" "nextcloud_db_pg" ];
      ensureUsers = [
      {
        name = "invidious";
        ensurePermissions."DATABASE invidious_db" = "ALL PRIVILEGES";
      } 
      {
	name = "firefly";
	ensurePermissions."DATABASE firefly_db" = "ALL PRIVILEGES";
      } 
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud_db_pg" = "ALL PRIVILEGES";
      } 
      ];
    };
}
