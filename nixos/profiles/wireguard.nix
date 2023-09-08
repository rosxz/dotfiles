{ self, config, lib, pkgs, ... }:
{
  age.secrets.wireguard-rnl-private = {
    file = "${self}/nixos/secrets/wireguard-rnl-private.age";
  };

  networking = {
    firewall = {
      allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
    };
    networkmanager.enable = true; # ??
  };

  networking.wg-quick.interfaces = {
    rnl = {
      address = [ "192.168.20.66/24" "fd92:3315:9e43:c490::66/64" ];
      dns = [
      "193.136.164.1"
      "193.136.164.2"
      "10.16.86.210"
      "10.16.86.211"
      ];
      privateKeyFile = config.age.secrets.wireguard-rnl-private.path;
      table = "765";
      postUp = ''
        ${pkgs.wireguard-tools}/bin/wg set rnl fwmark 765
        ${pkgs.iproute2}/bin/ip rule add not fwmark 765 table 765
        ${pkgs.iproute2}/bin/ip -6 rule add not fwmark 765 table 765
      '';
      postDown = ''
        ${pkgs.iproute2}/bin/ip rule del not fwmark 765 table 765
        ${pkgs.iproute2}/bin/ip -6 rule del not fwmark 765 table 765
      '';
      peers = [
        {
          publicKey = "g08PXxMmzC6HA+Jxd+hJU0zJdI6BaQJZMgUrv2FdLBY=";
          endpoint = "193.136.164.211:34266";
          allowedIPs = [
            "193.136.164.0/24"
            "193.136.154.0/24"
            "10.16.64.0/18"
            "2001:690:2100:80::/58"
            "192.168.154.0/24"
          ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
