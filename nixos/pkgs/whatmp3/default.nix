{ lib, pkgs, python3, fetchFromGitHub, ... }:
python3.pkgs.buildPythonApplication rec {
  pname = "whatmp3";
  version = "v3.81";

  # whatmp3 seems abandoned anyway so I'm using my own fork for the setup.py
  src = fetchFromGitHub rec {
    inherit pname version;
    name = pname;
    rev = version;
    owner = "rosxz";
    repo = "whatmp3";
    sha256 = "sha256-WXvXgaUtI4xt2e2hwWCNNEuvn5a+OtEH5TbwgkukLas=";
  };

  installPhase = ''install -Dm755 whatmp3.py $out/bin/whatmp3'';
  preFixup = ''
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [
      # Hard requirements
      pkgs.flac
      pkgs.lame # lmao
      # Optional deps depending on encoding types
      pkgs.opusTools
      pkgs.vorbis-tools
      pkgs.ffmpeg
      pkgs.vorbisgain
      pkgs.mp3gain
    ]})
  '';
}
