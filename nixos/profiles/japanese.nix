{ config, inputs, lib, pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
    ];
    fontconfig.defaultFonts = {
      serif = [ "Source Han Serif" ];
      sansSerif = [ "Source Han Sans" ];
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-configtool
    ];
  };

  environment.sessionVariables = rec {
    NIX_PROFILES =
        "${lib.concatStringsSep " " (lib.reverseList config.environment.profiles)}";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
  environment.variables.QT_PLUGIN_PATH = [ "${pkgs.fcitx5-with-addons}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];

  environment.systemPackages = with pkgs; [
    unstable.anki-bin
    tagainijisho
    unstable.goldendict-ng
    qolibri
    manga-ocr
  ];
}
