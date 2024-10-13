{ config, pkgs, sshKeys, user, profiles, ... }:
{
  imports = with profiles; [
    types.laptop # type of machine
    flavors.sway # window manager
    work
    wireguard
    polkit
    gdt
    docker
    dev
    entertainment
    ./hardware-configuration.nix
  ];

  home-manager.users.crea = {
    imports = with profiles.home; [ core neovim gammastep ];
    home.stateVersion = "23.05";
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  networking.hostId = "1dc334bc"; # For example: head -c 8 /etc/machine-id
  services.zfs.autoScrub.enable = true;

  i18n = {
    # defaultLocale = "ja_JP.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.utf8";
      LC_IDENTIFICATION = "pt_PT.utf8";
      LC_MEASUREMENT = "pt_PT.utf8";
      LC_MONETARY = "pt_PT.utf8";
      LC_NAME = "pt_PT.utf8";
      LC_NUMERIC = "pt_PT.utf8";
      LC_PAPER = "ja_JP.utf-8";
      LC_TELEPHONE = "pt_PT.utf8";
      LC_TIME = "ja_JP.utf-8";
    };
  };

  users.users.${user}.extraGroups = [ "qemu-libvirtd" "input" ];

  services.printing.enable = true;
  # services.fprintd = {
  #   enable = true;
  # };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true; # seems like a sddm issue

  environment.systemPackages = with pkgs; [
	  qbittorrent
	  yt-dlp
	  python3
	  xsettingsd
	  home-manager
    webcord-vencord
    gimp
    inkscape
  ];

  system.stateVersion = "22.11"; # Did you read the comment?
}
