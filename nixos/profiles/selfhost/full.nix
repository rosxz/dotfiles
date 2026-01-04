{ config, lib, pkgs, profiles, ... }: {

  #TODO: is this aight here?
  users.users.media = {
    # extraGroups = [ "docker" ];
    isSystemUser = true;
    group = "media";
  };
  users.groups.media = { };

  imports = with profiles.selfhost; [
    monitoring
    nginx
    jellyfin
    nextcloud
    postgresql
    rtorrent
    transmission
    betanin
  ];
    #gonic
    #bazarr
    #prowlarr
    #calibre # Broken in 25.05 in mysterious ways
    # polaris
    # Arrs
    #sonarr
  #unused
    #restic
    # invidious # not using until the new helper comes out # still borked
    #thelounge
    #homer
    #sonarr
    #radarr
    ##### finance
    # firefly
    # firefly-data-importer
}
