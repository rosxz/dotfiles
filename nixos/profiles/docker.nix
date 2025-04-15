{ config, pkgs, lib, user, ... }: {

  users.users.${user}.extraGroups = [ "docker" ]; # = ROOT, onl use if not rootless

  networking.firewall.trustedInterfaces = [ "docker0" ];
  # networking.networkmanager.unmanaged = [ "docker0" ];

  virtualisation.docker = {
    enable = true;
    #rootless = {
    #  enable = true;
    #  setSocketVariable = true;
    #};
  };
  environment.systemPackages = with pkgs; [
    # lazydocker
    unstable.docker-compose
  ];
}
