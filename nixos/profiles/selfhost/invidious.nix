{ self, config, lib, pkgs, ... }:

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
  #age.secrets.invidious-cookies = {
  #  file = "${self}/secrets/invidious-cookies.age";
  #  mode = "0440";
  #  owner = "root";
  #  group = "root";
  #};

  users.users.invidious = {
    isSystemUser = true;
    group = "invidious";
  };
  users.groups.invidious = {};

  services.invidious = {
    package = pkgs.unstable.invidious;
    #package = pkgs.unstable.invidious.overrideAttrs (oldAttrs: {
    #  patches = (oldAttrs.patches or []) ++ [
    #    (pkgs.fetchpatch {
    #      name = "invidious-upstream-fix.patch";
    #      url = "https://github.com/iv-org/invidious/commit/ad0a9eb9a36c8a022d2d573f5e36ca0bc9930543.patch";
    #      hash = "sha256-IUTJDe8gaxusc3qAKCmCokcudz3Dfh+ZWE23b3V2xqI="; 
    #    })
    #  ];
    #});
    enable = true;
    settings = {
      db = {
        user = "invidious";
        dbname = "invidious";
      };
      invidious_companion = [{
        private_url = "http://127.0.0.1:8282/companion";
        public_url = "https://inv.moniz.pt/companion";
      }];
      domain = domain;
      external_port = lib.mkForce 443;
      continue = true;
      local = false;
      check_tables = true;
      https_only = true;
      use_quic = false;
      admins = [ "creaai" ];
      registration_enabled = false;
      statistics_enabled = true;
    };
    domain = domain;
    port = 3001;
    nginx.enable = true;
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
    image = "quay.io/invidious/invidious-companion:master-5652eda";
    #image = "invidious-companion:patched";
    autoStart = true;
    user = "10001:10001";
    ports = [ "127.0.0.1:8282:8282/tcp" ];
    volumes = [
      "invidious-companion-cache:/var/tmp:rw"
      #"/var/lib/invidious-companion/config.toml:/app/config/config.toml:ro"
    ];
    extraOptions = [
      "--security-opt=no-new-privileges:true"
    ];
    environment = {
      CACHE_DIRECTORY = "/var/tmp";
      NETWORKING_VIDEOPLAYBACK_UMP = "false";
      NETWORKING_FETCH_RETRY_ENABLED = "true";
      NETWORKING_FETCH_RETRY_TIMES = "3";
      NETWORKING_FETCH_RETRY_INITIAL_DEBOUNCE = "500"; # ms
      NETWORKING_FETCH_RETRY_DEBOUNCE_MULTIPLIER = "2";
      #JOBS_YOUTUBE_SESSION_PO_TOKEN_ENABLED = "false";
      #YOUTUBE_SESSION_OAUTH_ENABLED = "true";
    };
    environmentFiles = [
      config.age.secrets.invidious-companion-key.path
    ];
  };

  ## 2. Fix the systemd triggers using a strict file presence condition
  #systemd.services.podman-invidious-companion = {
  #  # Blocks startup execution until the decrypted target is physically available
  #  unitConfig.ConditionPathExists = config.age.secrets.invidious-cookies.path;
  #  # Safely append your file copy routine using lib.mkAfter
  #  serviceConfig.ExecStartPre = lib.mkAfter [
  #    "${pkgs.writeShellScript "prepare-invidious-cookies" ''
  #      set -euo pipefail
  #      echo "[INFO] Syncing decrypted agenix cookie profile to container mount surface..."
  #      mkdir -p /var/lib/invidious-companion
  #      cp -f ${config.age.secrets.invidious-cookies.path} /var/lib/invidious-companion/config.toml
  #      chmod 644 /var/lib/invidious-companion/config.toml
  #      chown -R 10001:10001 /var/lib/invidious-companion
  #    ''}"
  #  ];
  #};

  ###### NGINX

  services.nginx.virtualHosts.${domain} = {
    enableACME = false;
    useACMEHost = "moniz.pt";
    forceSSL = true;
    locations."/companion" = {
      proxyPass = "http://127.0.0.1:8282";
    };
  };
}
