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
  ];

  xdg.desktopEntries.Anki = {
    name = "Anki";
    exec = "ANKI_WAYLAND=1 DISABLE_QT5_COMPAT=1 anki";
  };

  xdg.desktopEntries.Sonixd = {
    name = "Sonixd";
    exec = "sonixd";
  };

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
