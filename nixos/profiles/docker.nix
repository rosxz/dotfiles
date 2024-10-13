{ config, pkgs, lib, user, ... }: {

  users.users.${user}.extraGroups = [ "docker" ];

  networking.firewall.trustedInterfaces = [ "docker0" ];

  virtualisation.docker.enable = true;
  # networking.networkmanager.unmanaged = [ "docker0" ];
  environment.systemPackages = with pkgs; [
    lazydocker
    unstable.docker-compose
  ];
}
