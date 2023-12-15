{ self, config, pkgs, lib, profiles, ... }:

let RNLCert = builtins.fetchurl {
    url = "https://rnl.tecnico.ulisboa.pt/ca/cacert/cacert.pem";
    sha256 = "Qg7e7LIdFXvyh8dbEKLKdyRTwFaKSG0qoNN4KveyGwg=";
  };
in
{
  age.secrets.vault-agent-secret = {
    file = "${self}/secrets/vault-agent-secret.age";
    owner = "root";
    group = "root";
  };

  imports = with profiles; [
  ];

  security.pki.certificateFiles = ["${RNLCert}"];
  networking.search = [ "rnl.tecnico.ulisboa.pt" ];

  programs.zsh.shellAliases.ssh = lib.mkForce "vault write -field=signed_key ssh-client-signer/sign/rnl-admin public_key=@$HOME/.ssh/id_ed25519.pub > $HOME/.ssh/id_ed25519-cert.pub ; TERM=xterm-256color ssh";
  environment.sessionVariables = {
    VAULT_ADDR = "https://vault.rnl.tecnico.ulisboa.pt";
  };

  environment.systemPackages = with pkgs; [
    thunderbird-bin
    realvnc-vnc-viewer
    remmina
    vault
    waypipe

    virt-manager

    (ansible.overrideAttrs (old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ python3Packages.setuptools python3Packages.pywinrm ];
    }))
  ];
}

