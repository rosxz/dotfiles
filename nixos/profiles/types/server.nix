{ config, user, inputs, lib, pkgs, profiles, ... }: {

  imports = with profiles; [
    core
  ];

  modules.labels.type = "server";

  networking.networkmanager.enable = false;
  networking.firewall = {
    logRefusedConnections = false;
    allowedTCPPorts = [ 80 443 3000 8080 8081 8082 8089 9393 ]; #TODO: put this in respective places
  };

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
    kernelParams = [ "quiet" ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 6;
    };
  };
  services.fstrim.enable = true; # SSDs are the new normal

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  nix.settings = {
    trusted-users = [ "${user}" "root" ];
    allowed-users = [ "@wheel" ];
  };
  security.sudo.execWheelOnly = true;

  services.openssh.openFirewall = true;

  system.autoUpgrade = {
    enable = lib.mkDefault false; # dont want mailserver going down
    flake = "github:rosxz/dotfiles?dir=nixos";
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
    timers.clear-log = {
      wantedBy = [ "timers.target" ];
      partOf = [ "clear-log.service" ];
      timerConfig.OnCalendar = "weekly UTC";
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
}
