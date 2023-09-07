{ self, config, pkgs, sshKeys, ... }: {
  imports = with profiles; [
    types.server
    selfhost
    # distributedBuilds
    ./hardware-configuration.nix
  ];

  modules.services.hd-idle.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  networking = {
    hostId = "d72d0773"; # Seems more relevant for zfs
    dhcpcd.enable = false;

    defaultGateway = { # Router
      address = "192.168.1.1";
      interface = "enp2s0";
    };
    nameservers = [
      "1.1.1.1"
    ];
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

  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "*"; # Disable root

      crea = {
        isNormalUser = true;
        description = "Martim Moniz";
        extraGroups = [ "docker" "media" "video" "scanner" "qemu-libvirtd" "wheel" ];
        hashedPassword = "$6$WU1epwfq/D/h8Lny$Tcqfptb0ji/ZRIhB4uHzh1GISz3JegWVb1ZB0ZqfIzF5Vp/FzFVorqwi5npwRxCwzsSpOdLK5tdnlrB2pdz44/";
        openssh.authorizedKeys.keys = sshKeys;
      };

    };
  };

  environment.systemPackages = with pkgs; [
  	yt-dlp
  	xsettingsd

  	agenix
  ];

  services.fstrim = {
    enable = true;
    interval = "weekly"; # the default
  };

  system.stateVersion = "22.05";
}
