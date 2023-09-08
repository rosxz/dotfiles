{ config, lib, pkgs, ... }:

let domain = "prowlarr.moniz.pt";
in {
  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:9696";
    };

    prowlarr.enable = true;
    prowlarr.openFirewall = true;
  };
}
