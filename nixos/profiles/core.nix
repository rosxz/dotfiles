{ config, inputs, lib, pkgs, sshKeys, user, profiles, ... }:
{
  imports = with profiles; [
    tailscale
  ];

  networking = {
    networkmanager.enable = lib.mkDefault true;
    firewall.enable = lib.mkDefault true;
    firewall.checkReversePath = "loose";
  };

  time.timeZone = "Europe/Lisbon";
  i18n = lib.mkDefault {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.utf8";
      LC_IDENTIFICATION = "pt_PT.utf8";
      LC_MEASUREMENT = "pt_PT.utf8";
      LC_MONETARY = "pt_PT.utf8";
      LC_NAME = "pt_PT.utf8";
      LC_NUMERIC = "pt_PT.utf8";
      LC_PAPER = "pt_PT.utf8";
      LC_TELEPHONE = "pt_PT.utf8";
      LC_TIME = "pt_PT.utf8";
    };
  };
  console.keyMap = lib.mkDefault "pt-latin1";

  system.rebuild.enableNg = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Everything follows inputs
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/channels/nixpkgs" "unstable=/etc/channels/unstable"
    "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels" ];
  environment.etc."channels/nixpkgs".source = inputs.nixpkgs.outPath;
  nix.registry.unstable.flake = inputs.pin-unstable;
  environment.etc."channels/unstable".source = inputs.pin-unstable.outPath;

  # users.users.root.openssh.authorizedKeys.keys = lib.mkDefault (lib.mapAttrsToList (name: value: value) sshKeys);
  users.users.crea = {
    isNormalUser = true;
    description = "Martim Moniz";
    hashedPassword = "$6$g3erPleT4pElaQQe$fDIA/dckjSAADHRtjQt3RGrLmFE6TjZ5acdaRSTOBWA/8OuQlnDGr0FZUfGGqxJlS0vJDPDtpPzm6pJo7i96j0";
    extraGroups = [ "networkmanager" "cdrom" "video" "scanner" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = with sshKeys.users; [
      xiaomi navi ryuujin ebisu omigawa
    ];
  };
  users.users.root.hashedPassword = "*"; # Disable root user
  users.mutableUsers = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = lib.mkDefault true; # Need keys for age cba
    openFirewall = lib.mkDefault false;
    authorizedKeysFiles = pkgs.lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
  programs.mosh.enable = true;
  programs.ssh.startAgent = true;
  programs.nix-index = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
  };
  programs.command-not-found.enable = false;

#  xdg.terminal-exec = {
#    enable = true;
#    settings = {
#      default = [ "alacritty.desktop" ];
#    };
#  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    shellAliases = {
      poweroff = "poweroff --no-wall";
      reboot = "reboot --no-wall";
      rebuild = ''sudo nixos-rebuild switch --flake "github:rosxz/dotfiles?dir=nixos"'';
      tr = ''trash'';
      ssh = "TERM=xterm-256color ssh";
      ls = "eza --color=always --icons --group-directories-first";
      nix-alien=''nix run "github:thiagokokada/nix-alien#nix-alien" -- '';
    };
    interactiveShellInit = ''
   export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
   export FZF_BASE=${pkgs.fzf}/share/fzf/
   # Customize your oh-my-zsh options here
   plugins=(git fzf)
   HISTFILESIZE=1000
   HISTSIZE=1000
   setopt HIST_IGNORE_ALL_DUPS
   setopt HIST_IGNORE_DUPS
   setopt INC_APPEND_HISTORY
   autoload -U compinit && compinit
   unsetopt menu_complete
   setopt no_bare_glob_qual
   setopt completealiases
   source $ZSH/oh-my-zsh.sh
   eval "$(direnv hook zsh)"
   source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
   # setopt SHARE_HISTORY
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  };

  # Clean /tmp on boot
  environment.etc."tmpfiles.d/tmp.conf".text = ''
  #  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

# See tmpfiles.d(5) for details

# Clear tmp directories separately, to make them easier to override
D! /tmp 1777 root root 0
D /var/tmp 1777 root root 30d
  '';

  ## Garbage collector
  nix.gc = {
    automatic = true;
    #Every Monday 01:00 (UTC)
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Run garbage collection whenever there is less than 500MB free space left, prob better increase this value
  nix.extraOptions = ''
    min-free = ${toString (500 * 1024 * 1024)}

    keep-outputs = true
    keep-derivations = true
  ''; # DIRENV

  environment.systemPackages = with pkgs; [
    comma

    bat
    neovim
    stow
    fzf
    zsh-syntax-highlighting
    eza
    gettext
    git
    lf
    wget
    curl
    tmux
    ripgrep
    htop
    neofetch

    zip
    unzip
    rar
    unrar
    p7zip

    agenix
  ];

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
    '';
  };

  documentation = {
    dev.enable = false;
    man = {
      enable = true;
      generateCaches = false;
    };
  };

  system.stateVersion = lib.mkDefault "22.05";
}
