{ config, lib, pkgs, ... }: {

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  # Router Homepage

  services.nginx.virtualHosts = {
    "router.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://192.168.1.1";
    };
  };

  # Wildcard Let's Encrypt certificates

  security.acme = {
    acceptTerms = true;
    defaults = {
    	reloadServices = [ "nginx" ];
    	email = "robots@moniz.pt";
    	group = config.services.nginx.group;
      	dnsProvider = "cloudflare";
      	dnsPropagationCheck = true;
    };
    certs."moniz.pt" = {
      domain = "moniz.pt";
      extraDomainNames = [ "*.moniz.pt" ];
      credentialsFile = /var/lib/secrets/nginx/acme; # TODO
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  # Always use Nginx
  services.httpd.enable = lib.mkForce false;
  # Override the user and group to match the Nginx ones
  # Since some services uses the httpd user and group
  services.httpd = {
    user = lib.mkForce config.services.nginx.user;
    group = lib.mkForce config.services.nginx.group;
  };

  # HTTPS

  services.nginx.virtualHosts = {
    # Public
    "media.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:8096";
    };

#    "gonic.moniz.pt" = {
#      forceSSL = true;
#      useACMEHost = "moniz.pt";
#      locations."/".proxyPass = "http://127.0.0.1:4747";
#    };
    
#    "vault.moniz.pt" = {
#      forceSSL = true;
#      useACMEHost = "moniz.pt";
#      locations."/".proxyPass = "http://127.0.0.1:8855";
#    };

    # Private
    "grafana.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:3000";
    };

    "cloud.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
    };

    "flood.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:8082";
    };

    "sync.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:8384";
    };

    "slskd.moniz.pt" = {
      forceSSL = lib.mkForce true;
      useACMEHost = lib.mkForce "moniz.pt";
      locations."/".proxyPass = lib.mkForce "http://100.83.228.83:5030";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
