{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    jellyfin-media-player
    stremio
    mgba
    moonlight-qt
    steam-run
    protontricks
    wine-wayland
    waypipe
    steamtinkerlaunch
    # unstable.nexusmods-app # in the future maybe
    unstable.pcsx2
    unstable.lime3ds
  ];
  programs.steam.enable = true;
  # Waydroid
  # virtualisation.waydroid.enable = true;

  # install steam link thru flathub
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
}
