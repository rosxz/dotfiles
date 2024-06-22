{ config, pkgs, sshKeys, profiles, ... }: {

  imports = with profiles; [
    types.server
    mailserver
    ./hardware-configuration.nix
  ]; #TODO: filesystem.zfs ; server.impermanence

  # Bootloader.
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };
  zramSwap.enable = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    files = [
      "/etc/machine-id"
    ];

    directories = [
      "/var/log"
    ];
  };

  networking = {
    hostId = "84b55866"; # Seems more relevant for zfs
    useDHCP = false;
    dhcpcd.enable = false;

    defaultGateway = { # Router
      address = "185.162.248.1";
      interface = "ens3";
    };
    nameservers = [
      "1.1.1.1"
    ];

    interfaces.ens3 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "185.162.248.245";
        prefixLength = 22;
      }];
      ipv6.addresses = [{
        address = "2a03:4000:1a:25::";
        prefixLength = 64;
      }];
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword = "*"; # Disable root
      crea = {
        isNormalUser = true;
        description = "Martim Moniz";
        extraGroups = [ "media" "video" "scanner" "wheel" ];
        hashedPassword = "$y$j9T$yDGyhMdVtWOt8a7L9pSQw1$y5ZS5zo4KtcfIDxczVYM27.V8bR5OtHdA8PdF5KAY86";
        openssh.authorizedKeys.keys = sshKeys;
      };
    };
  };

  environment.systemPackages = with pkgs; [
	  yt-dlp
	  xsettingsd
    python311
  ];

  services.openssh = {
    hostKeys = [
    {
      bits = 4096;
      path = "/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    ];
  };

  system.stateVersion = "22.11";
}
