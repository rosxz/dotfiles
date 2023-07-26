{ config, pkgs, ... }:

{

imports = [ ./flood.nix ];

services.rtorrent = {
	enable = true;
	group = "media";
	port = 51432;
	openFirewall = true;
# 	configText = ''
# schedule2 = watch_directory_1,10,10,"load.start=~/Download/watch_stuff1/*.torrent,d.custom1.set=~/Download/stuff1/"
# schedule2 = watch_directory_2,10,10,"load.start=~/Download/watch_stuff2/*.torrent,d.custom1.set=~/Download/stuff2/"
# 
# method.insert = d.data_path, simple, "if=(d.is_multi_file), (cat,(d.directory),/), (cat,(d.directory),/,(d.name))"
# method.insert = d.move_to_complete, simple, "d.directory.set=$argument.1=; execute=mkdir,-p,$argument.1=; execute=mv,-u,$argument.0=,$argument.1=; d.save_full_session="
# method.set_key = event.download.finished,move_complete,"d.move_to_complete=$d.data_path=,$d.custom1="
# '';
	# dataDir
	downloadDir = "/mnt/Storage/Torrents/Unsorted";
};

services.flood = {
	enable = true;
	host = "0.0.0.0";
	port = 8082;
	group = "media";
	openFirewall = true;
	downloadDir = config.services.rtorrent.downloadDir;
};

}
