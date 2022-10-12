# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../modules/sway.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "ebisu"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.utf8";
      LC_IDENTIFICATION = "pt_PT.utf8";
      LC_MEASUREMENT = "pt_PT.utf8";
      LC_MONETARY = "pt_PT.utf8";
      LC_NAME = "pt_PT.utf8";
      LC_NUMERIC = "pt_PT.utf8";
      LC_PAPER = "pt_PT.utf8";
      LC_TELEPHONE = "pt_PT.utf8";
      LC_TIME = "pt_PT.utf8";
    };
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
      ];
    };
  };

  services.printing.enable = true;

  services.xserver.enable = true;

  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    theme = "maldives";
  };

  console.keyMap = "pt-latin1";
  
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.crea = {
    isNormalUser = true;
    description = "Martim Moniz";
    extraGroups = [ "networkmanager" "video" "scanner" "qemu-libvirtd" "wheel" ];
    shell = pkgs.zsh;
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    source-han-sans
    source-han-sans-japanese
    source-han-serif-japanese
  ];

  environment.sessionVariables = rec {
    # environment variables go here
    # export GDK_SCALE=2
    # export QT_AUTO_SCREEN_SCALE_FACTOR=2
  };

  environment.systemPackages = with pkgs; [
	networkmanagerapplet
	qbittorrent
	yt-dlp
	fzf
	exa
	gettext
	mpv
	mpd
	ncmpcpp
	git
  	alacritty
	neovim
	lf
	wget
	curl
	tmux
	unzip
	zip
	pciutils
	killall
	ripgrep
	htop
	python3
	neofetch
	xsettingsd
	pavucontrol
	home-manager
	spotify
	unstable.discord
  ];

  nixpkgs.overlays = [
    (self: super: {
      unstable.discord = super.unstable.discord.override { withOpenASAR = true; };
    })
  ];

  services.gnome.gnome-keyring.enable = true;
  
  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  programs.zsh = {
  	enable = true;
	shellAliases = {
		update = "sudo nixos-rebuild switch";
	};
  };

  system.stateVersion = "22.05"; 

}
