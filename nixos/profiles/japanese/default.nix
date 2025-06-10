{ config, inputs, lib, user, pkgs, ... }:
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
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
      ];
      waylandFrontend = config.modules.labels.display == "wayland";
      # TODO quickPhrase
    };
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
    # omigawa lacks "recent" CPU instruction sets (AVX, SSE?)
    customMpv = if config.networking.hostName == "omigawa" then
    (pkgs.mpv-unwrapped) else (pkgs.mpv-unwrapped.override {
      ffmpeg = pkgs.ffmpeg-full;
    });
    mpvWithScripts = pkgs.mpv-unwrapped.wrapper {
      mpv = customMpv;
      scripts = with pkgs.mpvScripts; [ mpvacious quality-menu ]; #uosc thumbfast
    };
  in
  [
    # tagainijisho
    # goldendict-ng
    # qolibri
    python312Packages.manga-ocr
    jellyfin-mpv-shim # edit config to use ext_mpv
    mpvWithScripts
  ] ++ (if config.networking.hostName == "omigawa" then [
    anki
  ] else [ anki-bin ]);

  home-manager.users.crea = {
    xdg.configFile."mpv/script-opts/subs2srs.conf".text = builtins.readFile ./subs2srs.conf;
    xdg.configFile."mpv/input.conf".text = builtins.readFile ./input.conf;
    xdg.configFile."mpv/mpv.conf".text = builtins.readFile ./mpv.conf;
  };
  #lib.recursiveUpdate {
}
