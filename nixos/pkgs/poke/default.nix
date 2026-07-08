{ lib, fetchFromGitHub, buildNpmPackage, pkgs, ... }:

buildNpmPackage rec {
  pname = "poke";
  version = "2026-07-04";

  src = fetchFromGitHub {
    owner = "ashleyirispuppy143";
    repo = "poke";
    rev = "3ba628077e18a061925a4ce235f68e4837c266a3";
    hash = "sha256-4na6DxfhQCVo+VtYr2oyU96WsMTR64UFeqw6xc8fmbE=";
  };

  npmDepsHash = lib.fakeHash;

  dontNpmBuild = true;
  npmFlags = [ "--legacy-peer-deps" ];

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.curl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/poke $out/bin
    cp -a . $out/share/poke/

    cat > $out/bin/poke <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

workdir="''${POKE_WORKDIR:-${placeholder "out"}/share/poke}"
cd "$workdir"
exec ${pkgs.nodejs}/bin/node server.js
EOF

    chmod 0755 $out/bin/poke

    runHook postInstall
  '';

  meta = with lib; {
    description = "PokeTube / Poke privacy-friendly YouTube front-end";
    homepage = "https://github.com/ashleyirispuppy143/poke";
    license = licenses.gpl3Plus;
    mainProgram = "poke";
    platforms = platforms.linux;
  };
}