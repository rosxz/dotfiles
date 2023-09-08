{ config, lib, pkgs, profiles, ... }: {

  #TODO: is this aight here?
  users.users.media = {
    # extraGroups = [ "docker" ];
    isSystemUser = true;
    group = "media";
  };
  users.groups.media = { };

  imports = with profiles.selfhost; [
    nginx
    jellyfin
    nextcloud
    postgresql
    invidious
    homer
    prowlarr
    bazarr
    rtorrent
    transmission
    betanin
  ];
}
