{ config, pkgs, user, profiles, lib, ... }:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };

in
{
  modules.labels.display = "wayland";

  imports = [

  ];

  services.xserver.desktopManager.xfce = {
    enable = true;
    enableWaylandSession = true;
    enableScreensaver = true;
  };

  environment.systemPackages = with pkgs; [
  ];
}
