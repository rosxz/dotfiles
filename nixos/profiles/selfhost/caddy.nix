{ pkgs, ... }: {
  services.caddy = {
    enable = true;

    extraConfig = ''
      inv.moniz.pt {
        reverse_proxy localhost:3000
      }
      media.moniz.pt:443 {
        reverse_proxy localhost:8096
      }
    '';
  };
}
