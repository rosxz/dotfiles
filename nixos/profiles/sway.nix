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
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland
      export NIXOS_OZONE_WL=1
    '';
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = false;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    displayManager = {
      defaultSession = "sway";
      gdm = {
        enable = true;
        autoSuspend = false;
        wayland = true;
      };
    };
    # displayManager = {
    #    defaultSession = "none+i3";
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  environment.sessionVariables.GTK_USE_PORTAL = "1"; # /NixOS/nixpkgs/pull/179204

  environment.systemPackages = with pkgs; [
    sway
    dbus-sway-environment
    glib
    swaylock-effects
    swayidle
    swaybg
    qt6.qtwayland
  ];
}
