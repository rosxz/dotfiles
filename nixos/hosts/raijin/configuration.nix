{ config, pkgs, sshKeys, profiles, ... }: {

  imports = with profiles; [
    types.desktop
    gnome # !!
    work
    entertainment
    polkit
    docker
    ./hardware-configuration.nix
  ];

  home-manager.users.crea = {
    imports = with profiles.home; [ core neovim gammastep ];
    home.stateVersion = "21.11";
  };

  networking = {
    firewall.enable = false;
    interfaces.enp4s0 = {
      ipv4 = {
        addresses = [{
          address = "193.136.164.197";
          prefixLength = 27;
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2001:690:2100:82::197";
          prefixLength = 64;
        }];
      };
    };
    defaultGateway = "193.136.164.222";
    nameservers = [ "193.136.164.1" "193.136.164.2" ];
  };

  services.printing.enable = true;
  services.xserver.libinput.enable = true; #TODO: ??

  users.users.crea = {
    isNormalUser = true;
    description = "Martim Moniz";
    hashedPassword = "$6$g3erPleT4pElaQQe$fDIA/dckjSAADHRtjQt3RGrLmFE6TjZ5acdaRSTOBWA/8OuQlnDGr0FZUfGGqxJlS0vJDPDtpPzm6pJo7i96j0";
    extraGroups = [ "networkmanager" "video" "scanner" "libvirtd" "qemu-libvirtd" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys;
  };

  # users.users.nixremote = {
  #   isNormalUser = true;
  #   description = "Nix remote builder";
  #   useDefaultShell = true;
  #   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAr7+pEOyGlRL4r5uUvQ8OK1tJMpqcH+eBdtZFusshk9 root@client" ];
  # };

  environment.sessionVariables = rec {
    # environment variables go here
    # export GDK_SCALE=2
    # export QT_AUTO_SCREEN_SCALE_FACTOR=2
  };

  environment.systemPackages = with pkgs; [
	  yt-dlp
	  python3
	  xsettingsd
	  home-manager
    webcord-vencord
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "22.05";
}
