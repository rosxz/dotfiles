{ self, config, pkgs, ... }:
let
  domain = "transmission.moniz.pt";
  # /tmp/transcodes would be cool but apparmor has restrictions
  downloadDir = "/storage-pool/Torrents";
  transcodeDir = "/storage-pool/Torrents/Transcodes"; # needs to be a subdir
in
{
  age.secrets.transmission-secrets = {
    file = "${self}/secrets/transmission-secrets.age";
    owner = "transmission";
  };

  age.secrets.betanin-api-key = {
    file = "${self}/secrets/betanin-api-key.age";
    owner = "transmission";
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:${
        toString config.services.transmission.settings.rpc-port
      }";
  };

  services.transmission = {
	enable = true;
	package = pkgs.transmission405.transmission_4;
	group = "media";
	openFirewall = true;
	openPeerPorts = true;
	settings = {
	  rpc-whitelist-enabled = true;
	  rpc-whitelist = "127.0.0.1,100.*.*.*";
	  rpc-host-whitelist-enabled = true;
	  rpc-host-whitelist = "*.moniz.pt";
	  rpc-authentication-required = false;

	  download-dir = downloadDir;
	  script-torrent-done-enabled = true;
	  script-torrent-done-filename = (pkgs.writers.writeBash "torrent-finished" ''
	  # MUSIC (whatmp3 transcode, beets tagging & import)
	  QUALITY="FLAC|MP3|V0|320|24bit|24-96|24-88.2"
	  TRACKERS="flacsfor.me|jpopsuki.eu" # Music trackers

	  if [[ $TR_TORRENT_NAME =~ .*($QUALITY).* ]] || [[ $TR_TORRENT_TRACKERS =~ .*($TRACKERS).* ]]; then
            echo "INFO: Running music torrent script for $TR_TORRENT_NAME"

	    ${pkgs.transmission_4}/bin/transmission-remote -t $TR_TORRENT_HASH --move ${downloadDir}/Music

            ln -s "${downloadDir}/Music/$TR_TORRENT_NAME" /tmp/$TR_TORRENT_HASH # Hopefuly this filename-guessing works
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
          '');
	};
	credentialsFile = config.age.secrets.transmission-secrets.path;
	# settings.watch-dir-enabled = false; # Change later
	# settings.trash-original-torrent-files = true;
	settings.message-level = 1;
  };
  #users.users.transmission = {
  #  extraGroups = [ "media" ];
  #};
}
