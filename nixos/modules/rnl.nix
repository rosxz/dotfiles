# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, lib, pkgs, ... }:

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # packer
    remmina

    virt-manager
    qemu_full
    dnsmasq
    bridge-utils
    netcat-openbsd
    vde2
    libguestfs

    realvnc-vnc-viewer
    thunderbird-bin
    (ansible.overrideAttrs (old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ python310Packages.pywinrm ];
    }))

    vault
  ];

  networking.firewall.enable = false;

  programs.zsh.shellAliases.ssh = lib.mkForce "vault write -field=signed_key ssh-client-signer/sign/rnl-admin public_key=@$HOME/.ssh/id_ed25519.pub > $HOME/.ssh/id_ed25519-cert.pub ; TERM=xterm-256color ssh";

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  environment.sessionVariables = {
    VAULT_ADDR = "http://vault.rnl.tecnico.ulisboa.pt";
  };

  security.pki.certificateFiles = ["${RNLCert}"];

  networking.search = [
    "rnl.tecnico.ulisboa.pt"
  ];
}

