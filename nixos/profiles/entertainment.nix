{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    jellyfin-media-player
    stremio
    mgba
  ];

  # install steam link thru flathub
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
}
