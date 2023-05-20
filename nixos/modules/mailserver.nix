   { self, config, pkgs, ... }:
   let
     release = "nixos-21.11";
   in {
     imports = [
       (builtins.fetchTarball {
         url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
         # This hash needs to be updated
         sha256 = "1i56llz037x416bw698v8j6arvv622qc0vsycd20lx3yx8n77n44";
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
               hashedPasswordFile = config.age.secrets.martim_at_moniz_passwd.path;

               aliases = [
                   "info@example.com"
                   "postmaster@example.com"
               ];
           };
       };

       certificateScheme = 3;
     };

     security.acme.acceptTerms = true;
     security.acme.defaults.email = "martim@moniz.pt";
   }
