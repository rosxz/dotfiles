{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    jellyfin-media-player
    stremio
    steam
    mgba
  ];
}
