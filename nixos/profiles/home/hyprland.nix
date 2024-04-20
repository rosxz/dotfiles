# home.nix
{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    systemd.enable = true;
    xwayland.enable = true;
    settings = {

    };
  };
}

