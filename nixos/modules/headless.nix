# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

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
    trustedInterfaces = [ "docker0" ];
  };

  hardware.bluetooth.enable = false;

  #Seperate user to run docker containers and other things on
  users.users.appuser = {
    uid = 1010;
    extraGroups = [ "docker" ];
    isSystemUser = true;
    group = "appuser";
  };
  users.groups.appuser = { };
  users.groups.media = { };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set automatic spin down of hard-drives
  services.hd-idle.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
}

