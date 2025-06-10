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
    #gonic
    nextcloud
    postgresql
    bazarr
    prowlarr
    rtorrent
    transmission
    betanin
    #calibre # Broken in 25.05 in mysterious ways
    restic
  ];
  #unused
    # invidious # not using until the new helper comes out # still borked
    #thelounge
    #homer
    #sonarr
    #radarr
    ##### finance
    # firefly
    # firefly-data-importer
}
