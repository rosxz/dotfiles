# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, lib, pkgs, ... }:

{

  imports = [];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    packer
    remmina
    # virt-manager
    realvnc-vnc-viewer
    thunderbird-bin
    ansible_2_13
  ];
  networking.resolvconf.extraOptions = [ "search rnl.tecnico.ulisboa.pt" ];

  # virtualisation.libvirtd.enable = true;

}

