# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, lib, pkgs, ... }:

{

  imports = [
	./hdd.nix
	./restic.nix
  ];

  networking.firewall.logRefusedConnections = false; #This is really spammy w/ pub. IPs. makes desg unreadable

  #Use latest linux-hardened kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 3000 8080 8081 8082 ];
  };

  hardware.bluetooth.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    # intel-gpu-tools # For debugging transcoding
  ];

  # Seperate user to run docker containers and other things on (see if i need that later)
  users.users.media = {
    # extraGroups = [ "docker" ];
    isSystemUser = true;
    group = "media";
  };
  users.groups.media = { };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set automatic spin down of hard-drives
  services.hd-idle.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
}

