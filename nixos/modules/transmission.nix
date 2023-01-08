# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  services.transmission = {
	enable = true;
	settings = {
	  rpc-username = "transmission";
	  rpc-authentication-required = true;
	  rpc-bind-address = "0.0.0.0";
	  rpc-whitelist = "100.*.*.*,127.0.0.1,192.168.*.*";
	};
	# settings.watch-dir-enabled = false; # Change later
	# settings.trash-original-torrent-files = true;
	settings.message-level = 3;
	credentialsFile = "/var/lib/secrets/transmission/transmission.json";
	openRPCPort = true;
	openPeerPorts = true;
  };
  users.users.transmission = {
    extraGroups = [ "media" ];
  };
}

