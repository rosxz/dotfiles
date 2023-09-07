{ self, config, pkgs, lib, profiles, ... }:

let RNLCert = builtins.fetchurl {
    url = "https://rnl.tecnico.ulisboa.pt/ca/cacert/cacert.pem";
    sha256 = "Qg7e7LIdFXvyh8dbEKLKdyRTwFaKSG0qoNN4KveyGwg=";
  };
in
{
  age.secrets.vault-agent-secret = {
    file = "${self}/nixos/secrets/vault-agent-secret.age";
    owner = "root";
    group = "root";
  };

  imports = with profiles; [
    wireguard
  ];

  security.pki.certificateFiles = ["${RNLCert}"];
  networking.search = [ "rnl.tecnico.ulisboa.pt" ];

  programs.zsh.shellAliases.ssh = lib.mkForce "vault write -field=signed_key ssh-client-signer/sign/rnl-admin public_key=@$HOME/.ssh/id_ed25519.pub > $HOME/.ssh/id_ed25519-cert.pub ; TERM=xterm-256color ssh";
  environment.sessionVariables = {
    VAULT_ADDR = "http://vault.rnl.tecnico.ulisboa.pt";
  };

  environment.systemPackages = with pkgs; [
    thunderbird-bin
    realvnc-vnc-viewer
    remmina
    vault

    virt-manager

    (ansible.overrideAttrs (old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ python310Packages.pywinrm ];
    }))
  ];
}
