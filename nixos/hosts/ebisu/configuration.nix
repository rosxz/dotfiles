# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, sshKeys, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/sway.nix
      ../../modules/syncthing.nix
      ../../modules/tailscale.nix
    ];

  # Bootloader.
  boot = {
    kernelParams = [ "quiet" ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 6;
    };
  };

  networking = {
    hostName = "ebisu"; # Define your hostname.
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" ];
    networkmanager.dns = "none";
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      server_names = [ "cloudflare" ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  services.xserver.libinput.enable = true;

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
    extraGroups = [ "networkmanager" "video" "scanner" "qemu-libvirtd" "wheel" "wireshark" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys;
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
	  lf
	  wget
	  curl
	  tmux
	  pciutils
	  killall
	  ripgrep
	  htop
	  python3
    mpv
	  neofetch
	  xsettingsd
	  pavucontrol
	  home-manager
	  spotify
	  (discord.override { nss = pkgs.nss_latest; }) # unlatest breaks nss_latest fix for firefox, but has openasar
	  brightnessctl
	  xarchiver
	  p7zip
	  rar
	  unrar
	  zip
	  unzip
	  pamixer
	  grim
	  slurp
	  thefuck
    # sddm-lain-wired-theme
  ];

  powerManagement = {
    powertop.enable = true;
  };
  services.auto-cpufreq.enable = true;
  # services.throttled.enable = true;
  services.thermald.enable = true;

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true; # seems like a sddm issue

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
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    shellAliases = {
      poweroff = "poweroff --no-wall";
      reboot = "reboot --no-wall";
      update = "nix flake update";
      rebuild = "sudo nixos-rebuild switch --flake .";
      ssh = "TERM=xterm-256color ssh";
      ls = "exa --color=always --icons --group-directories-first";
    };
    interactiveShellInit = ''
   export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
   export FZF_BASE=${pkgs.fzf}/share/fzf/
   # Customize your oh-my-zsh options here
   plugins=(git fzf thefuck)
   HISTFILESIZE=5000
   HISTSIZE=5000
   setopt SHARE_HISTORY
   setopt HIST_IGNORE_ALL_DUPS
   setopt HIST_IGNORE_DUPS
   setopt INC_APPEND_HISTORY
   autoload -U compinit && compinit
   unsetopt menu_complete
   setopt completealiases
   source $ZSH/oh-my-zsh.sh
    '';
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  };

  # Clean /tmp on boot
  environment.etc."tmpfiles.d/tmp.conf".text = ''
  #  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

# See tmpfiles.d(5) for details

# Clear tmp directories separately, to make them easier to override
D! /tmp 1777 root root 0
D /var/tmp 1777 root root 30d
  '';

#### Random stuff here ####
  programs.wireshark.package = pkgs.wireshark;
  programs.wireshark.enable = true;

  system.stateVersion = "22.05";

}
