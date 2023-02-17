{ config, lib, pkgs, ... }:

{
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
    defaults.email = "martim@moniz.pt";

    certs."moniz.pt" = {
      domain = "moniz.pt";
      extraDomainNames = [ "*.moniz.pt" ];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      credentialsFile = /var/lib/secrets/nginx/acme;
    };
  };
  
  users.users.nginx.extraGroups = [ "acme" ];

  # HTTPS

  services.nginx.virtualHosts = {
    # Public
    "media.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:8096";
    };

    "inv.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:3000";
    };

    # Private
    "flood.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:8082";
    };

    "firefly.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:8081";
    };

    "sync.moniz.pt" = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://100.83.228.83:8384";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
