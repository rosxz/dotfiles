{ config, lib, pkgs, ... }:

# Icons reference:
# - https://github.com/walkxcode/dashboard-icons/tree/main/svg
# - https://thehomelab.wiki/books/helpful-tools-resources/page/icons-for-self-hosted-dashboards
let domain = "homer.moniz.pt";
in {
  #virtualisation.oci-containers.containers.homer = {
  #  image = "b4bz/homer:latest";
  #  autoStart = true;
  #  ports = [ "127.0.0.1:8089:8080" ];
  #  volumes = [ "/var/lib/homer/assets:/www/assets" ];
  #  user = "1001";
  #};
  services.homer = {
    settings = 
  };

  services.nginx.virtualHosts.${domain} = {
    default = true;
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:8089";
  };
}
