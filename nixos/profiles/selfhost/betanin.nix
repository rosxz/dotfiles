{ config, lib, pkgs, ... }:

let domain = "betanin.moniz.pt";
in {
  # 1) Remove if not transcoding music downloads
  system.activationScripts = {
    transcodesDir.text = ''
    rm -rf /mnt/Storage/Torrents/Transcodes/*
    ''; # mkdir /mnt/Storage/Torrents/Transcodes
  };

  virtualisation.oci-containers.containers.betanin = {
    image = "sentriz/betanin:v0.5.5";
    autoStart = true;
    ports = [ "9393:9393" ];
    volumes = [ 
      "/var/lib/betanin/data:/b/.local/share/betanin/" 
      "/var/lib/betanin/config:/b/.config/betanin/" 
      "/var/lib/betanin/beets:/b/.config/beets/" 
      "/mnt/Storage/Shared/Music:/music/" 
      "/mnt/Storage/Torrents/:/downloads/" 
      "/mnt/Storage/Torrents/Transcodes/:/transcodes/" # 1)
    ];
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:9393";
  };
}
