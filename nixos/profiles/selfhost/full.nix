{ config, lib, pkgs, profiles, ... }: {

  #TODO: is this aight here?
  users.users.media = {
    # extraGroups = [ "docker" ];
    isSystemUser = true;
    group = "media";
  };
  users.groups.media = { };

  imports = with profiles.selfhost; [
    # polaris
    nginx
    jellyfin
    nextcloud
    postgresql
    bazarr
    prowlarr
    rtorrent
    transmission
    betanin
    calibre
    restic ##### Backups
    #thelounge
    #invidious # not using until the new helper comes out
    #homer
    #sonarr
    #radarr
    ##### finance
    # firefly
    # firefly-data-importer
  ];
}
