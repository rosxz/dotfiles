{ config, lib, pkgs, ... }:

let domain = "readeck.moniz.pt";
in {
  services.readeck = {
    enable = true;
    settings = {
      db = {
        type = "postgres";
	connection = ".
      };
    };
  };

  services.nginx.virtualHosts.${domain} = {
    default = true;
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:8089";
  };
}
