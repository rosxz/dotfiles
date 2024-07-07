{ config, inputs, lib, pkgs, profiles, ... }:
{
  imports = with profiles; [
    core
    display
    japanese
    syncthing
  ];

  # Change this later if needed
  services.openssh.openFirewall = true;

  boot = {
    kernelParams = [ "quiet" ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 6;
    };
    # plymouth.enable = true;
  };
  services.fstrim.enable = true; # SSDs are the new normal
}
