{ config, lib, pkgs, sshKeys, user, profiles, ... }: {

  imports = with profiles; [
    types.server
    selfhost.full
    syncthing # not all servers need it
    ./hardware-configuration.nix
    # distributedBuilds
  ];
  services.logrotate.checkConfig = false; ## FIXME: fix this workaround 

  ### ZFS
  boot.supportedFilesystems = [ "zfs" ];
  # swappiness=>This keeps the "real" RAM free for application level
  boot.kernelParams = [ "vm.swappiness=150" "zfs.zfs_arc_max=4294967296" ];
  zramSwap = {
    enable = true;
    memoryPercent = 15; # Limits zram to ~1.2GB
  };
  services.zfs.autoScrub.enable = true;
  ###

  system.autoUpgrade.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  networking = {
    hostId = "d72d0773"; # Seems more relevant for zfs
    dhcpcd.enable = false;

    defaultGateway = { # Router
      address = "192.168.1.1";
      interface = "enp2s0";
    };
    nameservers = [ "1.1.1.1" ];
    interfaces.enp2s0.ipv4.addresses = [{
      address = "192.168.1.80";
      prefixLength = 24;
    }];
    networkmanager.dns = "none";
    dhcpcd.extraConfig = "nohook resolv.conf";
  };

  #TODO: profile/module
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

      server_names = [ "cloudflare" ];
    };
  };

  users.users.${user} = {
    extraGroups = [ "docker" "media" "qemu-libvirtd" ];
    hashedPassword = lib.mkForce "$6$XXsj27JDo9EMVuj8$WGpN9hZtFUIIqj3buEYHDlOOIvlEVU.xGt/Qzel53momoesHkkjNwUwmm6a2AFDWlZI7R66vYpxipDtQC/N320";
  };

  environment.systemPackages = with pkgs; [
  	yt-dlp
  	xsettingsd
  	agenix
	whatmp3
  ];

  system.stateVersion = "22.05";
}
