{ self, config, pkgs, ... }: 
{
  age.secrets.invidious-db-pass = {
    file = "${self}/nixos/secrets/invidious-db-pass.age";
  };

  services.invidious = {
    package = pkgs.unstable.invidious;
    enable = true;
    settings = {
	db = {
  		user = "invidious_user";
  		# password = config.age.secrets.invidious-db-pass.path;
  		# host = "localhost";
  		# port = 5432;
  		dbname = "invidious_db";
	};
	check_tables = true;
	https_only = true;
	use_quic = true;
	admins = [ "creaai" ];
	registration_enabled = false;
    };
    database.passwordFile = config.age.secrets.invidious-db-pass.path;
  };
}
