{ config, lib, pkgs, ... }:

let
  domain = "calibre.moniz.pt";
  library = "/mnt/Storage/Shared/Books/Calibre";
in {
  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:${toString config.services.calibre-web.listen.port}";
    };

    calibre-server = {
      enable = true;
      user = "media";
      libraries = [ library ];
    };

    calibre-web = {
      enable = true;
      user = "media";
      listen.ip = "0.0.0.0";
      openFirewall = true;
      options = {
        enableBookUploading = true;
	enableBookConversion = true;
        calibreLibrary = library;
      };
    };
  };

  systemd.services.calibre-server.serviceConfig.ExecStart = lib.mkForce
    "${pkgs.calibre}/bin/calibre-server --userdb ${library}/users.sqlite --enable-auth ${library}";
}
