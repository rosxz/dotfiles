{ config, pkgs, inputs, ... }: {
  # GENERAL ENTERTAINMENT SOFTWARE
  environment.systemPackages = with pkgs; [
    jellyfin-media-player
    stremio
    moonlight-qt
    steam-run
    inputs.master.legacyPackages.x86_64-linux.protontricks
    wine-wayland
    waypipe
    steamtinkerlaunch
    lutris
  ];
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  # Enable waydroid per host
  # List of software to run with nix run
    #pcsx2
    #lime3ds
    #mgba

  # install steam link thru flathub
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
}
