{ self, config, lib, ... }:
{
  age.secrets.slskd-env-file = {
    file = "${self}/secrets/slskd-env-file.age";
    owner = "slskd";
  };
  services.slskd = {
    enable = true;
    group = "media";
    openFirewall = true;
    domain = "slskd.moniz.pt";
    environmentFile = config.age.secrets.slskd-env-file.path;
    settings = {
      shares.directories = [ ];
      directories.downloads = "/storage-pool/Shared/MusicSlsk";
    };
  };
  #systemd.services.slskd.serviceConfig = {
  #  ReadWritePaths = [ "/storage-pool/Shared/MusicSlsk" ];
  #  # Ensure the service can actually traverse the parent directories
  #  CapabilityBoundingSet = "CAP_CHOWN CAP_FOWNER"; 
  #};
}
