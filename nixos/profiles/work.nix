{ self, config, pkgs, lib, profiles, ... }:

let RNLCert = builtins.fetchurl {
    url = "https://rnl.tecnico.ulisboa.pt/ca/cacert/cacert.pem";
    sha256 = "020vnbvjly6kl0m6sj4aav05693prai10ny7hzr7n58xnbndw3j2";
  };
in
{
  imports = with profiles; [
    wireguard
  ];

  security.pki.certificateFiles = ["${RNLCert}"];
  networking.search = [ "rnl.tecnico.ulisboa.pt" ];

  programs.zsh.shellAliases = {
    ssh = lib.mkForce "vault write -field=signed_key ssh-client-signer/sign/rnl-admin public_key=@$HOME/.ssh/id_ed25519.pub > $HOME/.ssh/id_ed25519-cert.pub ; TERM=xterm-256color ssh";
    vault-login = "vault login -method='userpass' username='martim.monis'";
  };
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

