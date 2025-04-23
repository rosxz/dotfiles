{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = let
  	    # Use Boost with Python support explicitly enabled
	    pythonVersion = "312";
  	    boostWithPython = pkgs.boost.override {
  	      enablePython = true;
  	      python = pkgs.python3;
	      version = "1.81";
  	    };
	    # Create a derivation that provides the correctly named library
	    boostPythonCompat = pkgs.runCommand "boost-python-compat" {} ''
	      mkdir -p $out/lib
	      ln -s ${boostWithPython}/lib/libboost_python${pythonVersion}.so $out/lib/libboost_python.so
	      ln -s ${boostWithPython}/lib/libboost_python${pythonVersion}.so.${boostWithPython.version} $out/lib/libboost_python.so.${boostWithPython.version}
	    '';
	in pkgs.mkShell {
          buildInputs = with pkgs; [
	    apulse
	    alsa-lib
	    libffi
	    pkg-config
	    alsa-tools
	    alsa-utils
	    boostWithPython
	    boostPythonCompat
	    jack2
	    qjackctl
	    hydrogen
      jack-example-tools
	    # jack_rack # broken, for reverb apparently
          ];
	  shellHook = ''
    echo "Boost Python library path: ${boostWithPython}/lib/libboost_python312.so"
    echo "Using NIX_LDFLAGS: $NIX_LDFLAGS"
  '';
	  # Explicitly tell the linker where to find boost_python
  	  NIX_LDFLAGS = "-L${boostPythonCompat}/lib -lboost_python";
	  LD_LIBRARY_PATH = "${pkgs.pipewire.jack}/lib:${boostPythonCompat}/lib:${boostWithPython}/lib:${pkgs.lib.makeLibraryPath [pkgs.alsa-lib pkgs.jack2]}";
          # Helps `pip` find ALSA headers during compilation
  	  PKG_CONFIG_PATH = "${pkgs.alsa-lib}/lib/pkgconfig";
	  # Helps Python find Boost headers
  	  BOOST_INCLUDEDIR = "${boostWithPython.dev}/include";
	  BOOST_LIBRARYDIR = "${boostWithPython}/lib";
        };
        #apps.fhs_env = {
        #  type = "app";
        #  program = let drv = pkgs.buildFHSUserEnv {
        #    name = "idea-community";
        #    targetPkgs = pkgs: ( with pkgs; [
        #      jetbrains.idea-community
        #    ]);
        #    runScript = "idea-community";
        #  }; in "${drv}/bin/idea-community";
        #};
      }
    );
}
