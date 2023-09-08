{ config, pkgs, sshKeys, profiles, ... }:
{
  imports = with profiles; [
    types.laptop # type of machine
    gnome # window manager
    work
    polkit
    gdt
    entertainment
    ./hardware-configuration.nix
  ];

  home-manager.users.crea = {
    imports = with profiles.home; [ core neovim gammastep ];

    # modules = { git.enable = true; };

    home.stateVersion = "21.11";
  };

  users.users.crea = {
    isNormalUser = true;
    description = "Martim Moniz";
    extraGroups = [ "networkmanager" "video" "scanner" "qemu-libvirtd" "wheel" "input" "adbusers" ];
    shell = pkgs.zsh;
    # openssh.authorizedKeys.keys = sshKeys;
    hashedPassword = "$6$g3erPleT4pElaQQe$fDIA/dckjSAADHRtjQt3RGrLmFE6TjZ5acdaRSTOBWA/8OuQlnDGr0FZUfGGqxJlS0vJDPDtpPzm6pJo7i96j0";
  };
  users.users.root.hashedPassword = "*";
  users.mutableUsers = false;

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
