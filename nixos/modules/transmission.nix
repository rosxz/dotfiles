# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, pkgs, ... }:

{
  age.secrets.transmission = {
    file = "${self}/nixos/secrets/transmission.age";
    owner = "transmission";
    # group = "media";
  };

  services.transmission = {
	enable = true;
	settings = {
	  rpc-username = "transmission";
	  rpc-authentication-required = false;
	  rpc-bind-address = "0.0.0.0";
	  rpc-host-whitelist = "transmission.moniz.pt";
	  rpc-whitelist = "100.*.*.*,127.0.0.1,192.168.*.*";
	  download-dir = "/mnt/Storage/Torrents";
	  script-torrent-done-filename = "/mnt/scripts/transmission/transmission-done.sh";
	  script-torrent-done-enabled = true;
	};
	# settings.watch-dir-enabled = false; # Change later
	# settings.trash-original-torrent-files = true;
	settings.message-level = 3;
	credentialsFile = config.age.secrets.transmission.path;
	openRPCPort = true;
	openPeerPorts = true;
  };
  users.users.transmission = {
    extraGroups = [ "media" ];
  };
}

