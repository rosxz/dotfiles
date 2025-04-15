{ config, pkgs, user, profiles, lib, unstable, ... }:

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
    {  disabledModules = [ "services/x11/desktop-managers/xfce.nix" ]; }
    # (unstable + "/nixos/modules/services/x11/desktop-managers/xfce.nix")
    profiles.flavors.sway
  ];

  modules.services.xfce = {
    enable = true;
    enableWaylandSession = true;
    enableScreensaver = false;
    enableXfwm = false;
    waylandSessionCompositor = "sway";
  };
  # environment.xfce.excludePackages = [ pkgs.hicolor-icon-theme ];

  environment.systemPackages = with pkgs; [
    xfce.xfce4-taskmanager
    xfce.xfce4-genmon-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-clipman-plugin
    xfce.xfce4-timer-plugin
    xfce.xfce4-battery-plugin
    xfce.xfce4-sensors-plugin
    xfce.xfce4-systemload-plugin
    xfce.xfce4-cpugraph-plugin
    xfce.xfce4-notes-plugin
    jq # TODO only needed for xfce (wrap it?)
  ];
}
