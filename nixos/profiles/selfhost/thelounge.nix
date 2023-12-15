{ config, lib, pkgs, ... }:

let domain = "irc.moniz.pt";
in {
  imports = [];

  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:9000";
    };

    # Copied from: https://github.com/NixOS/nixpkgs/pull/203487 (cjv)
    thelounge = {
      enable = true;
      plugins = [ pkgs.theLoungePlugins.themes.mininapse pkgs.theLoungePlugins.themes.amoled ];
    };
  };
}
