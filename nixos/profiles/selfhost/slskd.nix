{ pkgs, lib,config, ... }:
{
  services.slskd = {
    enable = true;
    group = "media";
    openFirewall = true;
    environmentFile = 
    settings = {
      shares.directories = [ "/mnt/Shared/Music" ];
    };
  };
}
