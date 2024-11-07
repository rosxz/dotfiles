{ config, lib, pkgs, sshKeys, user, profiles, ... }:
let
  hostAddress = "192.168.1.81";
  gatewayAddress = "192.168.1.1";
  netmask = "255.255.255.0"; # /24
  interface = "enp5s0";
in
{
  imports = with profiles; [
    types.desktop # type of machine
    flavors.sway
    polkit
    work
    wireguard
    dev
    entertainment
    sunshine
    ./hardware-configuration.nix
  ];

  home-manager.users.crea = {
    imports = with profiles.home; [ core neovim gammastep ];
    home.stateVersion = "23.11";
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  zramSwap.enable = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
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
    extraGroups = [ "qemu-libvirtd" "input" ]; # "seat"
    openssh.authorizedKeys.keys = with sshKeys; lib.mkForce [ user_ryuujin user_xiaomi ];
  };

  services.printing.enable = true;
  # services.fprintd = {
  #   enable = true;
  # };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true; # seems like a sddm issue
  networking.interfaces.${interface}.wakeOnLan.enable = true;

  ## Remote ZFS Decryption
  boot = {
    # Set up static IPv4 address in the initrd.
    kernelParams = [ "ip=${hostAddress}::${gatewayAddress}:${netmask}::${interface}:none" ];

    initrd = {
      # Switch this to your ethernet's kernel module.
      # You can check what module you're currently using by running: lspci -v
      kernelModules = [ "r8169" ];

      network = {
        # This will use udhcp to get an ip address.
        # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
        # so your initrd can load it!
        # Static ip addresses might be configured using the ip argument in kernel command line:
        # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
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
        # this will automatically load the zfs password prompt on login
        # and kill the other prompt so boot can continue
        postCommands = ''
          cat <<EOF > /root/.profile
          if pgrep -x "zfs" > /dev/null
          then
            zfs load-key -a
            killall zfs
          else
            echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
          fi
          EOF
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    qbittorrent
    yt-dlp
    python3
    xsettingsd
    home-manager
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
