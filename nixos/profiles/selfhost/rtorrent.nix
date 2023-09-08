{ config, pkgs, modules, ... }:
{
  services.rtorrent = {
  	enable = true;
  	group = "media";
  	port = 51432;
  	openFirewall = true;
  	# configText
  	# dataDir
  	downloadDir = "/mnt/Storage/Torrents";
  };

  modules.services.flood = {
  	enable = true;
  	host = "0.0.0.0";
  	port = 8082;
  	group = "media";
  	openFirewall = true;
  	downloadDir = config.services.rtorrent.downloadDir;
  };
}
