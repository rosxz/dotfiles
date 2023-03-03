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
    anki-bin
    sonixd
    unstable.kdenlive
    zathura
    man-pages
    libreoffice-qt
    krita
    xournalpp
    libqalculate
    jellyfin-media-player

    patchelf
    jetbrains.idea-community
    easyrpg-player
  ];

  xdg.desktopEntries.Anki = {
    name = "Anki";
    exec = "ANKI_WAYLAND=1 DISABLE_QT5_COMPAT=1 anki";
  };

  xdg.desktopEntries.Sonixd = {
    name = "Sonixd";
    exec = "sonixd";
  };

  xdg.desktopEntries.visual-studio-code = {
    type = "Application";
    name = "Visual Studio Code";
    exec = "NIXOS_OZONE_WL=1 code"; # Still not working
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
