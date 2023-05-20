   { self, config, pkgs, ... }:
   let
     release = "nixos-21.11";
   in {
     imports = [
       (builtins.fetchTarball {
         url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
         # This hash needs to be updated
         sha256 = "0000000000000000000000000000000000000000000000000000";
       })
     ];

     age.secrets.martim_at_moniz_passwd = {
       file = "${self}/nixos/secrets/martim_at_moniz_passwd.age";
       owner = "root";
       group = "root";
     };

     mailserver = {
       enable = true;
       fqdn = "mail.moniz.pt";
       domains = [ "moniz.pt" ];
       loginAccounts = {
           "martim@moniz.pt" = {
               # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt' > /hashed/password/file/location
               hashedPasswordFile = config.age.secrets.nextcloud-db-pass.path;

               aliases = [
                   "info@example.com"
                   "postmaster@example.com"
               ];
           };
       };

       certificateScheme = 3;
     };
   }
