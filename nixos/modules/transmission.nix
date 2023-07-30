# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, pkgs, ... }:

let 
  # /tmp/transcodes would be cool but apparmor has restrictions
  downloadDir = "/mnt/Storage/Torrents/";
  transcodeDir = "/mnt/Storage/Torrents/Transcodes/"; # needs to be a subdir
in
{
  age.secrets.transmission = {
    file = "${self}/nixos/secrets/transmission.age";
    owner = "transmission";
  };
  
  age.secrets.betanin-api-key = {
    file = "${self}/nixos/secrets/betanin-api-key.age";
    owner = "transmission";
  };

  services.transmission = {
	enable = true;
	package = with pkgs; unstable.transmission_4;
	settings = {
	  rpc-username = "transmission";
	  rpc-authentication-required = false; # eh, its privated so wtv
	  rpc-bind-address = "0.0.0.0";
	  rpc-host-whitelist = "transmission.moniz.pt";
	  rpc-whitelist = "100.*.*.*,127.0.0.1,192.168.*.*";
	  download-dir = downloadDir;
	  script-torrent-done-enabled = true;
	  script-torrent-done-filename = (pkgs.writers.writeBash "torrent-finished" ''
	  # MUSIC (whatmp3 transcode, beets tagging & import)
	  QUALITY="FLAC|MP3|V0|320|24bit|24-96|24-88.2"
	  TRACKERS="flacsfor.me|jpopsuki.eu" # Music trackers

	  if [[ $TR_TORRENT_NAME =~ .*($QUALITY).* ]] || [[ $TR_TORRENT_TRACKERS =~ .*($TRACKERS).* ]]; then
            echo "INFO: Running music torrent script for $TR_TORRENT_NAME"
	    
	    ${pkgs.transmission}/bin/transmission-remote -t $TR_TORRENT_HASH --move ${downloadDir}/Music

            ln -s "${downloadDir}Music/$TR_TORRENT_NAME" /tmp/$TR_TORRENT_HASH # Hopefuly this filename-guessing works
	    ${pkgs.whatmp3}/bin/whatmp3 -nrz --V0 -o ${transcodeDir} /tmp/$TR_TORRENT_HASH

	    ${pkgs.curl}/bin/curl \
    --request POST \
    --data-urlencode "path=/transcodes/" \
    --data-urlencode "name=$TR_TORRENT_HASH (V0)" \
    --header "X-API-Key: $(cat ${config.age.secrets.betanin-api-key.path})" \
    "https://betanin.moniz.pt/api/torrents"

	    # Cleanup
	    rm /tmp/$TR_TORRENT_HASH
	  fi
          ''); # if not transcoding, then replace path and name in request and read activationScript
	};
	# settings.watch-dir-enabled = false; # Change later
	# settings.trash-original-torrent-files = true;
	settings.message-level = 1;
	credentialsFile = config.age.secrets.transmission.path;
	openRPCPort = true;
	openPeerPorts = true;
  };
  users.users.transmission = {
    extraGroups = [ "media" ];
  };
}

