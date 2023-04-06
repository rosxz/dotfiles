{ config, lib, pkgs, ... }:

let domain = "sonarr.moniz.pt";
in {
  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:8989";
    };

    sonarr = {
      enable = true;
      user = "media";
      openFirewall = true;
    };
  };
}
