{ config, lib, pkgs, ... }:

let domain = "radarr.moniz.pt";
in {
  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:7878";
    };

    radarr = {
      enable = true;
      user = "media";
      openFirewall = true;
    };
  };
}

