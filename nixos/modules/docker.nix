{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;
  # networking.networkmanager.unmanaged = [ "docker0" ];
  environment.systemPackages = with pkgs; [
    lazydocker
    unstable.docker-compose
  ];
}
