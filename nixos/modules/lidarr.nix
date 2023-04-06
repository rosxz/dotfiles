{ config, lib, pkgs, ... }:

let domain = "lidarr.moniz.pt";
in {
  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:8686";
    };

    lidarr = {
      enable = true;
      user = "media";
    };
  };
}
