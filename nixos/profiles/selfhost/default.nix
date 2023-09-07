{ config, lib, pkgs, ... }: {

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
