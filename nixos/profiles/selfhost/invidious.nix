{ self, config, pkgs, ... }:

let domain = "inv.moniz.pt";
in {
  age.secrets.invidious-extra-settings = {
    file = "${self}/secrets/invidious-extra-settings.age";
    owner = "invidious";
    group = "invidious";
  };

  age.secrets.invidious-db-pass = {
    file = "${self}/secrets/invidious-db-pass.age";
  };
  age.secrets.invidious-companion-key = {
    file = "${self}/secrets/invidious-companion-key.age";
  };

  users.users.invidious = {
    isSystemUser = true;
    group = "invidious";
  };
  users.groups.invidious = {};

  services.invidious = {
    package = pkgs.unstable.invidious;
    enable = true;
    settings = {
        db = {
            user = "invidious";
            dbname = "invidious";
	};
	invidious_companion = {
	  private_url = "http://127.0.0.1:8282";
	  public_url = "http://100.83.228.83:9393";
	};
	domain = domain;
	continue = true;
	local = true;
	check_tables = true;
	https_only = true;
	use_quic = true;
	quality = "dash";
	quality_dash = "best";
	admins = [ "creaai" ];
	registration_enabled = false;
	statistics_enabled = true;
    };
    domain = domain;
    nginx.enable = true;
    http3-ytproxy.enable = true;
    extraSettingsFile = config.age.secrets.invidious-extra-settings.path;
    database = {
    	passwordFile = config.age.secrets.invidious-db-pass.path;
	createLocally = false;
    };
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

  ###### Companion

  virtualisation.oci-containers.containers.invidious-companion = {
    image = "quay.io/invidious/invidious-companion:master-626f421";
    autoStart = true;
    user = "10001:10001";
    ports = [ "127.0.0.1:8282:8282/tcp" ];
    volumes = [
      "invidious-companion-cache:/var/tmp/youtubei.js:rw"
    ];
    extraOptions = [
      "--security-opt=no-new-privileges:true"
    ];
    environmentFiles = [
      config.age.secrets.invidious-companion-key.path
    ];
  };

  ###### NGINX

  services.nginx.virtualHosts.${domain} = {
    enableACME = false;
    useACMEHost = "moniz.pt";
  };
}
