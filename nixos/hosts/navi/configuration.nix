{ config, lib, pkgs, sshKeys, user, profiles, ... }:
  let
  hostAddress = "192.168.1.81";
  gatewayAddress = "192.168.1.1";
  prefixLength = 24;
  interface = "enp5s0";
  #utsushi-net = (pkgs.utsushi.override { withNetworkScan = true; });
in
{
  imports = with profiles; [
    types.desktop # type of machine
    flavors.gnome
    docker
    virtualisation
    entertainment
    #sunshine
    ./hardware-configuration.nix
  ];

  home-manager.users.crea = {
    imports = with profiles.home; [ core neovim gammastep ];
    home.stateVersion = "23.11";
  };

  #modules.distributed_builds = {
  #  enable = true;
  #  type = "remote";
  #};
  virtualisation.waydroid.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  zramSwap.enable = true;
  #services.journald.storage = "persistent";
  #hardware.rasdaemon.enable = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  networking.hostId = "0bf65e23"; # For example: head -c 8 /etc/machine-id
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

  users.users.${user} = {
    extraGroups = [ "qemu-libvirtd" "input" "adbusers" "scanner" "lp"]; # "seat"
    openssh.authorizedKeys.keys = with sshKeys; lib.mkForce [ users.ryuujin users.xiaomi users.raijin ];
  };

  #services.printing = {
  #  enable = true;
  #  drivers = [ pkgs.epson-escpr ];
  #};
  #hardware.sane = {
  #  enable = true;
  #  openFirewall = true;
  #  netConf = "192.168.1.75";
  #  extraBackends = [ utsushi-net ];
  #  disabledDefaultBackends = [ "v4l" ];
  #};
  #services.udev.packages = [ utsushi-net ];
  # services.fprintd = {
  #   enable = true;
  # };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true; # seems like a sddm issue
  networking.interfaces.${interface}.wakeOnLan.enable = true;
  networking.networkmanager.ensureProfiles.profiles.enp5s0 = {
    connection = {
      id = "enp5s0";
      type = "ethernet";
      interface-name = interface;
      autoconnect = true;
      autoconnect-priority = 100;
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };

  ## Remote ZFS Decryption
  boot = {
    initrd = {
      # Keep initrd DNS independent from NetworkManager in stage 2.
      services.resolved.enable = false;

      # Switch this to your ethernet's kernel module.
      # You can check what module you're currently using by running: lspci -v
      kernelModules = [ "r8169" ];

      systemd.network.networks."10-${interface}" = {
        matchConfig.Name = interface;
        address = [ "${hostAddress}/${toString prefixLength}" ];
        gateway = [ gatewayAddress ];
        linkConfig.RequiredForOnline = "routable";
      };
      network = {
        enable = true;
        ssh = {
          enable = true;
          # To prevent ssh clients from freaking out because a different host key is used,
          # a different port for ssh is useful (assuming the same host has also a regular sshd running)
          port = 2222;
          # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
          # the keys are copied to initrd from the path specified; multiple keys can be set
          # you can generate any number of host keys using
          # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
          hostKeys = [ /etc/ssh/ssh_host_ed25519_2_key ];
          # public ssh key used for login
          authorizedKeys = config.users.users.${user}.openssh.authorizedKeys.keys;
        };
      };
    };
  };
  # this will automatically load the zfs password prompt on login
  # and kill the other prompt so boot can continue
  boot.initrd.systemd.services.zfs-remote-unlock = {
    description = "Prepare root .profile for ZFS unlocking via SSH";
    wantedBy = [ "initrd.target" ];
    before = [ "initrd-root-fs.target" ];
    unitConfig.DefaultDependencies = false;

    script = ''
      mkdir -p /var/empty
      echo "systemd-tty-ask-password-agent --watch" > /var/empty/.profile
    '';

    serviceConfig.Type = "oneshot";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    unstable.qbittorrent
    yt-dlp
    python3
    xsettingsd
    home-manager
    boxbuddy
    distrobox
    vesktop
    unstable.krita
    android-tools
  ];

  #services.ollama = {
  #  enable = true;
  #  loadModels = [
  #    "deepseek-r1:1.5b"
  #    "llama3:8b"
  #  ];
  #  acceleration = "rocm";
  #};
  #services.nextjs-ollama-llm-ui.enable = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
