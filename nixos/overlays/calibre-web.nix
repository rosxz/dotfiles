self: super: rec {
  calibre-web = super.calibre-web.overrideAttrs (old: {
    passthru.optional-dependencies = {
        kobo = [ super.python310Packages.jsonschema ];
    };
    propagatedBuildInputs = old.propagatedBuildInputs ++ calibre-web.optional-dependencies.kobo;
  });
}
