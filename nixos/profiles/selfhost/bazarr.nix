{ config, lib, pkgs, ... }:

let domain = "bazarr.moniz.pt";
in {
  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:6767";
    };

    bazarr = {
      enable = true;
      user = "media";
      openFirewall = true;
    };
  };
}

