# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, pkgs, sshKeys, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/tailscale.nix
      ../../modules/mailserver.nix
    ];

  # Bootloader.
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "quiet" ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 6;
    };
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
    hostName = "hachiman";
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

    networkmanager.dns = "none";
    dhcpcd.extraConfig = "nohook resolv.conf";
    firewall.checkReversePath = "loose";
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

      server_names = [ "cloudflare" ];
    };
  };

  ## Enable BBR module
  boot.kernelModules = [ "tcp_bbr" ];

  ## Network hardening and performance
  boot.kernel.sysctl = {
    # Disable magic SysRq key
    "kernel.sysrq" = 0;
    # Ignore ICMP broadcasts to avoid participating in Smurf attacks
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    # Ignore bad ICMP errors
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Reverse-path filter for spoof protection
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;
    # Do not accept ICMP redirects (prevent MITM attacks)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    # Do not send ICMP redirects (we are not a router)
    "net.ipv4.conf.all.send_redirects" = 0;
    # Do not accept IP source route packets (we are not a router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    # Protect against tcp time-wait assassination hazards
    "net.ipv4.tcp_rfc1337" = 1;
    # TCP Fast Open (TFO)
    "net.ipv4.tcp_fastopen" = 3;
    ## Bufferbloat mitigations
    # Requires >= 4.9 & kernel module
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Requires >= 4.19
    "net.core.default_qdisc" = "cake";
  };

  nix.settings.trusted-users = [
    "crea"
    "root"
  ];
  nix.settings.allowed-users = [ "@wheel" ];

  security.sudo.execWheelOnly = true;

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
  };

  console.keyMap = "pt-latin1";

  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "*"; # Disable root

      crea = {
        isNormalUser = true;
        description = "Martim Moniz";
        extraGroups = [ "media" "video" "scanner" "wheel" ];
        hashedPassword = "$6$WU1epwfq/D/h8Lny$Tcqfptb0ji/ZRIhB4uHzh1GISz3JegWVb1ZB0ZqfIzF5Vp/FzFVorqwi5npwRxCwzsSpOdLK5tdnlrB2pdz44/";
        openssh.authorizedKeys.keys = sshKeys;
      };

    };
  };

  environment.systemPackages = with pkgs; [
	yt-dlp
	gettext
	git
	exa
	lf
	wget
	curl
	unzip
	zip
	pciutils
	killall
	htop
	neofetch
	xsettingsd
  python311
	agenix
  neovim
  ];

  services.fstrim = {
    enable = true;
    interval = "weekly"; # the default
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    kbdInteractiveAuthentication = false;
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
    authorizedKeysFiles = pkgs.lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
    # extraConfig = '' ''; # dont need this for now
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/home/crea/.navifiles/nixos";
    allowReboot = true;
    # Daily 00:00
    dates = "daily UTC";
  };

  ## Optional: Clear >1 month-old logs
  systemd = {
    services.clear-log = {
      description = "Clear >1 month-old logs every week";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-time=30d";
      };
    };
    services.dnscrypt-proxy2.serviceConfig = {
      StateDirectory = "dnscrypt-proxy";
    };
    timers.clear-log = {
      wantedBy = [ "timers.target" ];
      partOf = [ "clear-log.service" ];
      timerConfig.OnCalendar = "weekly UTC";
    };
  };

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
   HISTFILESIZE=5000
   HISTSIZE=5000
   setopt SHARE_HISTORY
   setopt HIST_IGNORE_ALL_DUPS
   setopt HIST_IGNORE_DUPS
   setopt INC_APPEND_HISTORY
   autoload -U compinit && compinit
   unsetopt menu_complete
   setopt completealiases
    '';
  };

  ## Garbage collector
  nix.gc = {
    automatic = true;
    #Every Monday 01:00 (UTC)
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  # Run garbage collection whenever there is less than 500MB free space left, prob better increase this value
  nix.extraOptions = ''
    min-free = ${toString (500 * 1024 * 1024)}
  '';

  system.stateVersion = "22.11";
}
