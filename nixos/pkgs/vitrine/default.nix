{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  python3,
  gtk4,
  libadwaita,
  glib,
  gobject-introspection,
  gdk-pixbuf,
  graphene,
  pango,
  harfbuzz,
  webkitgtk_6_0,
  libsoup_3,
  gst_all_1,
  adwaita-icon-theme,
  hicolor-icon-theme,
  legendary-gl,
  gogdl,
  umu-launcher,
  comet-gog,
  desktop-file-utils,
  runtimeShell,
  ...
}:
let
  # D3D runtime DLLs (DirectX 9/10/11 helpers) used to populate Wine prefixes
  # so legacy Windows games launch. Mirrored from the repo's flake.nix.
  d3dExtras = stdenv.mkDerivation {
    pname = "d3d_extras";
    version = "v2";
    src = fetchurl {
      url = "https://github.com/lutris/d3d_extras/releases/download/v2/v2.tar.xz";
      sha256 = "1bvkn1jvdrmgwj0l5fwbwgiv2f77g50k2xfnq1gqclvvjj3aq5wi";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out"
      tar -xJf "$src" --strip-components=1 -C "$out"
    '';
  };

  # Python interpreter bundled with the app's runtime deps. Everything else the
  # app dlopens at runtime (GTK/WebKit/GStreamer typelibs) is exposed through
  # the env vars computed below, exactly as the flake does.
  runtimePython = python3.withPackages (ps: [
    ps.pygobject3
    ps.requests
    ps.pillow
  ]);

  runtimeLibs = [
    gtk4
    libadwaita
    glib
    gobject-introspection
    gdk-pixbuf
    graphene
    pango
    harfbuzz
    webkitgtk_6_0
    libsoup_3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];
  runtimeThemes = [ adwaita-icon-theme hicolor-icon-theme ];

  # Shared library search path for dlopened deps.
  libraryPath = lib.makeLibraryPath (runtimeLibs ++ runtimeThemes);
  # Typelibs ship in the ``out`` output of every dependency, which is not always
  # the default output (pango's default is its ``bin`` output).
  typelibPath = lib.concatStringsSep ":" (map (p: "${p.out}/lib/girepository-1.0") runtimeLibs);
  # Where GIO/GStreamer look for schemas, icons and plugins.
  dataDirs = lib.concatStringsSep ":" (map (p: "${p}/share") (runtimeLibs ++ runtimeThemes));
  gstPlugins = with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ];
  gstPluginPath = lib.concatStringsSep ":" (map (p: "${p}/lib/gstreamer-1.0") gstPlugins);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vitrine";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "rosxz";
    repo = "vitrine";
    rev = "fc05bda82d31a359ead5ab2ac1008e0b6c54de1c";
    hash = "sha256-lqNoRiU+ZWXWzXLkg56Jf0S8G5sHpboTvVYGqoNRF/c=";
  };

  sourceRoot = "source";

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/python
    # Ship the whole `vitrine` package tree, not just the subpackages listed in
    # pyproject.toml (artwork_providers/ and wine/ are omitted there but needed).
    cp -r vitrine $out/lib/python/vitrine

    # Desktop integration: .desktop, AppStream metadata, icons.
    mkdir -p $out/share/applications $out/share/metainfo \
      $out/share/icons/hicolor/scalable/apps \
      $out/share/icons/hicolor/512x512/apps
    cat > $out/share/applications/io.github.rosxz.vitrine.desktop <<'DESKTOP'
    [Desktop Entry]
    Type=Application
    Name=Vitrine
    Comment=A unified game library launcher
    Exec=vitrine %U
    TryExec=vitrine
    Icon=io.github.rosxz.vitrine
    Terminal=false
    Categories=Game;
    Keywords=game;launcher;steam;gog;epic;
    StartupNotify=true
    X-GNOME-UsesNotifications=true
    DESKTOP
    ${desktop-file-utils}/bin/desktop-file-validate $out/share/applications/io.github.rosxz.vitrine.desktop
    cp packaging/flatpak/io.github.rosxz.vitrine.metainfo.xml $out/share/metainfo/
    # The repo ships a single 512px PNG app icon (no separate SVG/scalable copy).
    cp packaging/flatpak/icons/io.github.rosxz.vitrine.png $out/share/icons/hicolor/512x512/apps/
    cp packaging/flatpak/icons/io.github.rosxz.vitrine.png $out/share/icons/hicolor/scalable/apps/io.github.rosxz.vitrine.png

    # Entry point. Store paths below are resolved at build time so they end up
    # in the closure; the module sys.path is pointed at the copied package tree.
    mkdir -p $out/bin
    cat > $out/bin/vitrine <<'WRAPPER'
    #!${runtimeShell}
    export VITRINE_LEGENDARY="${legendary-gl}/bin/legendary"
    export VITRINE_GOGDL="${gogdl}/bin/gogdl"
    export VITRINE_D3D_EXTRAS="${d3dExtras}"
    export VITRINE_UMU="${umu-launcher}/bin/umu-run"
    export VITRINE_COMET="${comet-gog}/bin/comet"
    export PYTHONPATH="${placeholder "out"}/lib/python"
    export LD_LIBRARY_PATH="${libraryPath}:$LD_LIBRARY_PATH"
    export GI_TYPELIB_PATH="${typelibPath}:$GI_TYPELIB_PATH"
    export XDG_DATA_DIRS="${dataDirs}:$XDG_DATA_DIRS"
    export GST_PLUGIN_SYSTEM_PATH="${gstPluginPath}:$GST_PLUGIN_SYSTEM_PATH"
    exec ${runtimePython}/bin/python -m vitrine "$@"
    WRAPPER
    chmod +x $out/bin/vitrine

    runHook postInstall
  '';

  meta = with lib; {
    description = "A unified game library launcher for Linux: local games, Steam (owned + family shared), GOG and Epic, with artwork and playtime tracking";
    homepage = "https://github.com/rosxz/vitrine";
    license = licenses.gpl3Plus;
    mainProgram = "vitrine";
    platforms = [ "x86_64-linux" ];
  };
})
