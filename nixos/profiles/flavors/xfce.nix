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
  # FOR XFCE PANEL GENMON PLUGIN
  workspaces-sway = pkgs.writeTextFile {
    name = "workspaces-sway.sh";
    executable = true;
    text = ''
#!/bin/sh

GENMON=$(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel -l -v | ${pkgs.busybox}/bin/awk -F'[-/]' '/workspaces/ {print $4}')

${pkgs.sway}/bin/swaymsg -t subscribe -m '["workspace"]' | while read -r line; do
  ${pkgs.xfce.xfce4-panel}/bin/xfce4-panel --plugin-event=genmon-$GENMON:refresh:bool:true
done
    '';
  };
in
{
  modules.labels.display = "wayland";

  imports = [
    profiles.flavors.sway
  ];

  # Append to extraConfig
  home-manager.users.${user}.wayland.windowManager.sway.extraConfig = lib.mkAfter ''
     exec xfce4-session
     exec ${workspaces-sway}
  '';

  services.xserver.xfce = {
    enable = true;
    enableWaylandSession = true;
    enableScreensaver = false;
    enableXfwm = false;
    # waylandSessionCompositor = "sway";
  };

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
