# home.nix
{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    systemd.enable = true;
  };
}

