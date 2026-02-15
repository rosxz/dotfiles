{ self, config, pkgs, ... }:

let 
  domain = "sygnal.moniz.pt";
  sygnalConfig = pkgs.writeText "sygnal.yaml" ''
    apps:
      app.cinny.mobile:
        type: gcm
        api_version: v1
        project_id: "cinny-mobile"
        # Note: This path is INSIDE the container
        service_account_file: /sygnal/fcm.json

      # Future iOS configuration
      #app.cinny.mobile.ios:
      #  type: apns
      #  keyfile: /etc/sygnal/apns.p8
      #  key_id: "ABC123DEFG"
      #  team_id: "XYZ789HIJK"
      #  topic: "app.cinny.mobile"

    http:
      port: 5000
      bind_addresses: ['0.0.0.0']

    metrics:
      prometheus:
        enabled: true
        address: "0.0.0.0"
        port: 8000
    log:
      setup:
        version: 1
        formatters:
          precise:
            format: '%(asctime)s [%(name)s] %(levelname)s: %(message)s'
        handlers:
          stderr:
            class: "logging.StreamHandler"
            formatter: "precise"
            stream: "ext://sys.stderr"
        root:
          handlers: ["stderr"]
          level: INFO
  '';
in {
  age.secrets.sygnal-fcm = {
    file = "${self}/secrets/sygnal-fcm.age";
    mode = "0444";
  };

  virtualisation.oci-containers.containers.sygnal = {
    image = "matrixdotorg/sygnal:latest";
    autoStart = true;
    ports = [ "5000:5000" "8000:8000" ];
    environment = {
      SYGNAL_CONF = "/sygnal/sygnal.yaml";
    };
    volumes = [
      "${sygnalConfig}:/sygnal/sygnal.yaml:ro"
      "${config.age.secrets.sygnal-fcm.path}:/sygnal/fcm.json:ro"
    ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemMaxFileSize=200M
  '';

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:5000";
  };

  networking.firewall.allowedTCPPorts = [ 8000 ];
}
