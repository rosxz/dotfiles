{ pkgs, ... }:

{
  services.caddy = {
    enable = true;
    
    extraConfig = ''
      inv.moniz.pt {
        reverse_proxy localhost:3000
      }
      media.moniz.pt:443 {
        reverse_proxy localhost:8096
      }
      sync.moniz.pt {
        reverse_proxy localhost:8384
      }
      budget.moniz.pt {
        reverse_proxy localhost:8081
      }
      lair.moniz.pt {
	reverse_proxy localhost:8082
      }
      nextcloud.moniz.pt:443 {
        reverse_proxy localhost:11000
      }
      nextcloud.moniz.pt:8443 {
        reverse_proxy https://localhost:8080 {
          transport http {
            tls_insecure_skip_verify
          }
        }
      }
    '';
  };

}
