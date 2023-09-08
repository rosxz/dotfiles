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
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
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

  # environment.sessionVariables.QT_STYLE_OVERRIDE = lib.mkForce "adwaita-dark";

  # Enable sound with pipewire.
  sound.enable = true;
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

  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        autoSuspend = lib.mkDefault false;
        wayland = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # wayland specific
    wayland
    xwayland
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wlogout

    # tools
    networkmanagerapplet
    alacritty
    pavucontrol
    mpv
    pamixer
	  brightnessctl
	  xarchiver # thunar
    configure-gtk

    # |_> wayland specific tools
	  grim
	  slurp
    imv
    firefox-wayland
    waybar
    wofi
    mako
    xdg-utils # for opening default programs when clicking links
    swww # stupid wallpaper software

    # theming
    kora-icon-theme
    bibata-cursors-translucent
    adwaita-qt
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme  # default gnome cursors
  ];
}
