{ config, pkgs, sshKeys, user, profiles, ... }:
{
  imports = with profiles; [
    types.laptop # type of machine
    gnome # window manager
    work
    docker
    polkit
    gdt
    entertainment
    ./hardware-configuration.nix
  ];

  home-manager.users.crea = {
    imports = with profiles.home; [ core neovim gammastep ];
    home.stateVersion = "21.11";
  };

  users.users.${user}.extraGroups = [ "qemu-libvirtd" "input" "adbusers" ];

  services.printing.enable = true;
  # services.fprintd = {
  #   enable = true;
  # };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true; # seems like a sddm issue

  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
	  qbittorrent
	  yt-dlp
	  python3
	  xsettingsd
	  home-manager
	  (discord.override { nss = pkgs.nss_latest; withOpenASAR = true; }) # unlatest breaks nss_latest fix for firefox, but has openasar
  ];
}
