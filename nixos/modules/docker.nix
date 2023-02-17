{ config, pkgs, lib, ... }:

{
  networking.firewall.trustedInterfaces = [ "docker0" ];

  # Seperate user to run docker containers and other things on
  users.users.appuser = {
    uid = 1010;
    extraGroups = [ "docker" ];
    isSystemUser = true;
    group = "appuser";
  };
  users.groups.appuser = { };
  users.groups.media = { };

  virtualisation.docker.enable = true;
  # networking.networkmanager.unmanaged = [ "docker0" ];
  environment.systemPackages = with pkgs; [
    lazydocker
    unstable.docker-compose
  ];
}
