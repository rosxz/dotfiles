{ config, pkgs, ... }:

{
  imports = [
    ../../modules/gammastep.nix
    ../../modules/neovim.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "crea";
  home.homeDirectory = "/home/crea";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    page
    unstable.anki-bin
    sonixd
    unstable.kdenlive
    zathura
    man-pages
    # libreoffice-qt
    krita
    xournalpp
    libqalculate
    jellyfin-media-player

    patchelf
    # easyrpg-player
    mgba

    # godot_4
    # aseprite-unfree
    # blender
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  xdg.desktopEntries.Anki = {
    name = "Anki";
    exec = ''env ANKI_WAYLAND=1 anki''; # DISABLE_QT5_COMPAT=1 # Bugged
  };

  xdg.desktopEntries.Sonixd = {
    name = "Sonixd";
    exec = "sonixd";
  };

  xdg.desktopEntries.visual-studio-code = {
    type = "Application";
    name = "Visual Studio Code";
    exec = ''env NIXOS_OZONE_WL=1 code'';
  };

  programs.vscode = {
    enable = true;
    package = with pkgs; unstable.vscode;
    extensions = with pkgs; [
      vscode-extensions.dracula-theme.theme-dracula
      vscode-extensions.redhat.java
      vscode-extensions.vscjava.vscode-maven
      vscode-extensions.vscjava.vscode-java-test
      vscode-extensions.vscjava.vscode-java-dependency
      vscode-extensions.vscjava.vscode-spring-initializr
      vscode-extensions.vscjava.vscode-java-debug
      unstable.vscode-extensions.github.copilot
    ];
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
# Assume hosts without fqdn come from RNL
CanonicalizeHostname yes
CanonicalDomains rnl.tecnico.ulisboa.pt
CanonicalizeMaxDots 0

Match originalhost lab*,!lab*.rnl.tecnico.ulisboa.pt
  HostName dolly.rnl.tecnico.ulisboa.pt
  User root
  RemoteCommand ssh %n
  ForwardAgent no
  RequestTTY yes

Match canonical host="*.rnl.tecnico.ulisboa.pt"
  User root
  ServerAliveInterval 60

Host *.rnl.tecnico.ulisboa.pt *.rnl.ist.utl.pt
  User root
  ServerAliveInterval 60''; # TODO: put this in a proper place
  };

  home.file.".config/gtk-3.0/settings.ini".text = ''
  [Settings]
  gtk-cursor-theme-name=Bibata_Ghost
  '';
  home.file.".icons/default".source = "${pkgs.bibata-cursors-translucent}/share/icons/Bibata_Ghost";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
