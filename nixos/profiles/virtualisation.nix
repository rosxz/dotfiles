{ self, user, config, pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
  };
  #virtualisation.useSecureBoot = true;
  #virtualisation.tpm.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings
  environment.systemPackages = with pkgs; [ virt-manager ];

  users.users.${user}.extraGroups = [ "libvirtd" ];
}
