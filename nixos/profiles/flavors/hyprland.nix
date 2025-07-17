{ config, pkgs, user, profiles, lib, ... }:

let
  dbus-hyprland-environment = pkgs.writeTextFile {
    name = "dbus-hyprland-environment";
    destination = "/bin/dbus-hyprland-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };
  configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
        gsettings set $gnome_schema icon-theme 'kora'
        gsettings set $gnome_schema cursor-theme 'Bibata_Ghost'
        '';
  };
in
{
  modules.labels.display = "wayland";

  programs = {
    hyprland = {
      ## package = pkgs.pinnedHyrpland.hyprland;
      enable = true;
      ## withUWSM = true;
    };
    dconf.enable = true;
  };
  services.hypridle.enable = true;

  # import wm config
  home-manager.users.${user} = {
    imports = with profiles.home; [ hyprland wofi waybar ];
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    config.common.default = [ "*" ];
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  environment.sessionVariables.GTK_USE_PORTAL = "1"; # /NixOS/nixpkgs/pull/179204

  environment.systemPackages = with pkgs; [
    dbus-hyprland-environment
    glib
    qt6.qtwayland
    wayvnc
  ];
}
