{ config, inputs, lib, pkgs, ... }:
{
  modules.labels.langlearn = true;

  fonts = {
    packages = with pkgs; [
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
      corefonts
      vistafonts
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

  environment.systemPackages = with pkgs; let
    customMpv = (pkgs.mpv-unwrapped.override {
      ffmpeg = pkgs.ffmpeg_5-full;
    });
    mpvWithScripts = pkgs.wrapMpv customMpv {
      scripts = [ pkgs.mpvScripts.mpvacious ];
    };
  in
  [
    unstable.anki-bin
    tagainijisho
    unstable.goldendict-ng
    qolibri
    manga-ocr
    jellyfin-mpv-shim # edit config to use ext_mpv
    mpvWithScripts
  ];

  home-manager.users.crea = {
    xdg.configFile."mpv/script-opts/subs2srs.conf".text = builtins.readFile ./subs2srs.conf;
  };
}
