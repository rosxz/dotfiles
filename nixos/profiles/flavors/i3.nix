{ config, pkgs, user, lib, ... }:

let
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
  modules.labels.display = "xorg";

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  services.xrdp = {
    enable = true;
    # TODO get session executable without string regex :)
    defaultWindowManager = builtins.head (builtins.elemAt (builtins.split ".+Exec=([^\n]+)"
      (builtins.head config.services.xserver.displayManager.sessionPackages).text) 1);
    openFirewall = true;
  };
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status-rust # gives you the default i3 status bar
        i3lock-fancy-rapid #default i3 screen locker
     ];
    };
    displayManager = {
      #lightdm.enable = true;
      defaultSession = "xfce+i3";
      #defaultSession = "none+i3";
    };
  };

  #services.xserver.screenSection = ''
  #  Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
  #  Option         "AllowIndirectGLXProtocol" "off"
  #  Option         "TripleBuffer" "on"
  #'';

  xdg.portal.enable = true;
  environment.systemPackages = with pkgs; [
    configure-gtk
    glib # gsettings

    rofi
  ];
}
