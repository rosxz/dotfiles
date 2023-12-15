self: super: rec {
  calibre-web = super.calibre-web.overrideAttrs (old: {
    passthru.optional-dependencies = {
        kobo = [ super.python3Packages.jsonschema ];
    };
    preFixup = ''
      makeWrapperArgs+=(--prefix PATH : ${super.lib.makeBinPath [
        super.kepubify
      ]})
    '';

    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.python3Packages.setuptools
      super.kepubify ] ++ calibre-web.optional-dependencies.kobo;
  });
}
