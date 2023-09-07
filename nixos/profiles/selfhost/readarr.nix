{ config, lib, pkgs, ... }:

let domain = "readarr.moniz.pt";
in {
  # imports = [ (pkgs.fetchFromGitHub "/nixos-unstable/nixos/modules/services/misc/readarr.nix") ];
  imports = [];

  services = {
    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "moniz.pt";
      locations."/".proxyPass = "http://127.0.0.1:8787";
    };

    # Copied from: https://github.com/NixOS/nixpkgs/pull/203487 (cjv)
    readarr = {
      enable = true;
      user = "media";
    };
  };
}
