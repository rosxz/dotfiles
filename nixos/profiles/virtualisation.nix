{ self, user, config, pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings
  environment.systemPackages = with pkgs; [ virt-manager ];

  users.users.${user}.extraGroups = [ "libvirtd" ];
}
