{ self, config, pkgs, ... }: {

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
              "@moniz.pt"
            ];
        };
    };

    certificateScheme = "acme-nginx";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "martim+letsencrypt@moniz.pt";

  environment.persistence."/persist".directories = [
    "/var/lib/rspamd"
    {
     directory = "/var/vmail";
      user = "virtualMail";
      group = "virtualMail";
    }
    {
      directory = "/var/dkim";
      user = "opendkim";
      group = "opendkim";
    }
    "/var/lib/acme"
  ];
}
