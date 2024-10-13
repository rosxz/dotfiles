{ config, pkgs, lib, ... }:

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

  programs.wayfire = {
    enable = true;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
    #extraSessionCommands = ''
    #  export QT_QPA_PLATFORM=wayland
    #  export NIXOS_OZONE_WL=1
    #'';
  };

  #services.dbus.enable = true;
  #xdg.portal = {
  #  enable = true;
  #  wlr.enable = true;
  #  # gtk portal needed to make gtk apps happy
  #  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  #};
  #environment.sessionVariables.GTK_USE_PORTAL = "1"; # /NixOS/nixpkgs/pull/179204

  environment.systemPackages = with pkgs; [
    #dbus-sway-environment
    glib # gsettings
    #swaylock-effects
    #swayidle
    #swaybg
    qt6.qtwayland
  ];
}
