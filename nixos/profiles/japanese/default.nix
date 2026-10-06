{ config, inputs, lib, user, pkgs, ... }:
let
  ocrPython = pkgs.python314.withPackages (ps: [ ps.manga-ocr ]);

  manga-ocr-once = pkgs.writeTextFile {
    name = "manga-ocr-once";
    executable = true;
    destination = "/bin/manga-ocr-once";
    text = ''
      #!${ocrPython}/bin/python3
      import sys
      from manga_ocr import MangaOcr

      print(MangaOcr()(sys.argv[1]))
    '';
  };

  manga-ocr-daemon = pkgs.writeTextFile {
    name = "manga-ocr-daemon";
    executable = true;
    destination = "/bin/manga-ocr-daemon";
    text = "#!${ocrPython}/bin/python3\n" + builtins.readFile ./manga-ocr-daemon.py;
  };

  manga-ocr-clip = pkgs.writeShellApplication {
    name = "manga-ocr-clip";
    runtimeInputs = with pkgs; [
      gjs
      wl-clipboard
      libnotify
      coreutils
      manga-ocr-once
      manga-ocr-daemon
    ];
    text = ''
      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT

      sock="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/manga-ocr.sock"

      notify() {
        notify-send -a manga-ocr "$1" "$2"
      }

      if [ "''${1:-}" = "--clipboard" ]; then
        path="$tmp/clipboard.png"
        if ! wl-paste --type image/png > "$path" 2>/dev/null; then
          notify "manga-ocr" "No image in clipboard"
          exit 1
        fi
      else
        path="$(gjs ${./manga-ocr-shot.js})"
        [ -n "$path" ] || exit 0
      fi

      if [ ! -S "$sock" ]; then
        systemctl --user start manga-ocr-daemon.service 2>/dev/null || true
        i=0
        while [ "$i" -lt 60 ] && [ ! -S "$sock" ]; do
          sleep 0.25
          i=$((i + 1))
        done
      fi

      if [ -S "$sock" ]; then
        text="$(manga-ocr-daemon client "$sock" "$path" 2>/dev/null)"
      else
        text="$(manga-ocr-once "$path" 2>/dev/null)"
      fi
      rm -f "$path"

      if [ -z "$text" ]; then
        notify "manga-ocr" "No text detected"
        exit 0
      fi

      printf '%s' "$text" | wl-copy >/dev/null 2>&1
      notify "manga-ocr (copied to clipboard)" "$text"
    '';
  };
in
{
  modules.labels.langlearn = true;

  fonts = {
    packages = with pkgs; [
      source-han-sans
      source-han-serif
      corefonts
      vista-fonts
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
        qt6Packages.fcitx5-configtool
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
  environment.variables.QT_PLUGIN_PATH = [ "${pkgs.qt6Packages.fcitx5-with-addons}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];

  environment.systemPackages = with pkgs; let
    # omigawa lacks "recent" CPU instruction sets (AVX, SSE?)
    customMpv = if config.networking.hostName == "omigawa" then
    (pkgs.mpv-unwrapped) else (pkgs.mpv-unwrapped.override {
      ffmpeg = pkgs.ffmpeg-full;
    });
    mpvWithScripts = pkgs.mpv.override {
      mpv-unwrapped = customMpv;
      scripts = with pkgs.mpvScripts; [ mpvacious quality-menu ]; #uosc thumbfast
    };
  in
  [
    # tagainijisho
    # goldendict-ng
    # qolibri
    python314Packages.manga-ocr
    manga-ocr-clip
    jellyfin-mpv-shim # edit config to use ext_mpv
    mpvWithScripts
  ] ++ (if config.networking.hostName == "omigawa" then [
    anki
  ] else [ anki-bin ]);

  home-manager.users.crea = {
    xdg.configFile."mpv/script-opts/subs2srs.conf".text = builtins.readFile ./subs2srs.conf;
    xdg.configFile."mpv/input.conf".text = builtins.readFile ./input.conf;
    xdg.configFile."mpv/mpv.conf".text = builtins.readFile ./mpv.conf;

    systemd.user.services.manga-ocr-daemon = lib.mkIf config.services.desktopManager.gnome.enable {
      Unit = {
        Description = "Resident manga-ocr server";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${manga-ocr-daemon}/bin/manga-ocr-daemon serve %t/manga-ocr.sock";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    dconf.settings = lib.mkIf config.services.desktopManager.gnome.enable {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/manga-ocr/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/manga-ocr-clipboard/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/manga-ocr" = {
        name = "Manga OCR: select region";
        command = "${manga-ocr-clip}/bin/manga-ocr-clip";
        binding = "<Super>o";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/manga-ocr-clipboard" = {
        name = "Manga OCR: image from clipboard";
        command = "${manga-ocr-clip}/bin/manga-ocr-clip --clipboard";
        binding = "<Super><Shift>o";
      };
    };
  };
  #lib.recursiveUpdate {
}
