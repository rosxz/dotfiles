{ config, lib, pkgs, profiles, ... }:
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
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      font-awesome
      ibm-plex
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "IBM Plex Mono" ];
    };
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = config.modules.labels.display == "wayland";
  };

  # environment.sessionVariables.QT_STYLE_OVERRIDE = lib.mkForce "adwaita-dark";

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  ### PACKAGES
  environment.systemPackages = let
    common = with pkgs; [
      # tools
      networkmanagerapplet
      alacritty
      pavucontrol
      pamixer
	    brightnessctl
      configure-gtk
      trashy
      xdg-utils # for opening default programs when clicking links
      xarchiver

      # theming
      kora-icon-theme
      bibata-cursors-translucent
      adwaita-qt
      dracula-theme # gtk theme
      adwaita-icon-theme  # default gnome cursors
    ];
    displayPackages = with pkgs; if config.modules.labels.display == "wayland" then
      [
        wayland
        xwayland
        wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
        wlogout
          # tools
	      grim
	      slurp
        imv
        firefox-wayland
        waybar
        mako
        swww # stupid wallpaper software
      ]
    else
      [
        feh
        flameshot
        firefox-bin
      ];
    langLearnPackages = with pkgs; if !config.modules.labels.langlearn then
      [ mpv ] else [];
  in common ++ displayPackages ++ langLearnPackages;
}
