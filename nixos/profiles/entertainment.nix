{ config, pkgs, inputs, ... }: {
  # GENERAL ENTERTAINMENT SOFTWARE
  environment.systemPackages = with pkgs; [
    stremio
    steam-run
    wine-wayland
    steamtinkerlaunch
    (lutris.override {
      extraPkgs = internalPkgs: [ pkgs.mangohud ];
    })
  ];
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  # Enable waydroid per host
  # List of software to run with nix run
    #pcsx2
    #lime3ds
    #mgba
    #protontricks
    #moonlight-qt
    #jellyfin-media-player

  # install steam link thru flathub
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
}
