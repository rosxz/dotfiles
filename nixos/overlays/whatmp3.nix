{ inputs, ... }@args: self: super: rec {
  
  whatmp3 = super.python3Packages.buildPythonApplication rec {
    pname = "whatmp3";
    version = "v3.81";
  
    # whatmp3 seems abandoned anyway so I'm using my own fork for the setup.py
    src = super.fetchFromGitHub rec {
      inherit pname version;
      name = pname;
      rev = version;
      owner = "creaaidev";
      repo = "whatmp3";
      sha256 = "sha256-WXvXgaUtI4xt2e2hwWCNNEuvn5a+OtEH5TbwgkukLas=";
    };
  
    installPhase = ''install -Dm755 whatmp3.py $out/bin/whatmp3'';
    preFixup = ''
      makeWrapperArgs+=(--prefix PATH : ${args.lib.makeBinPath [ 
        # Hard requirements
        super.flac
        super.lame # lmao
        # Optional deps depending on encoding types
        super.opusTools
        super.vorbis-tools
        super.ffmpeg
        super.vorbisgain
        super.mp3gain
      ]})
    '';
  };
}
