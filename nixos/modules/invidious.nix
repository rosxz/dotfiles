{ self, config, lib, pkgs, ... }: 
{
  age.secrets.invidious-extra-settings = { # NOT WORKING, AS INVIDIOUS USER DOESN'T EXIST AT A CERTAIN MOMENT FOR WHATEVER REASON
    file = "${self}/nixos/secrets/invidious-extra-settings.age";
    owner = "invidious";
    group = "invidious";
  };

  age.secrets.invidious-db-pass = {
    file = "${self}/nixos/secrets/invidious-db-pass.age";
  };

  services.invidious2 = { # temporary service with fix
    package = pkgs.unstable.invidious;
    enable = true;
    settings = {
	db = {
  		user = "invidious_user";
  		dbname = "invidious_db";
	};
	check_tables = true;
	https_only = true;
	use_quic = true;
        quality = "dash";
        quality_dash = "best";
	admins = [ "creaai" ];
	registration_enabled = false;
    };
    extraSettingsFile = config.age.secrets.invidious-extra-settings.path;
    database.passwordFile = config.age.secrets.invidious-db-pass.path;
  };

  systemd.timers."invidious-reset" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar="hourly";
        Persistent=true;
        Unit = "invidious-reset.service";
      };
  };

  systemd.services."invidious-reset" = {
      script = ''
        ${pkgs.systemd}/bin/systemctl restart invidious.service
      '';
      serviceConfig = {
        Type="oneshot";
        User="root";
      };
  };
}
