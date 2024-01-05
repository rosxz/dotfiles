{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}: let
  version = "1.4.0";
  php = pkgs.php83;
in
  php.buildComposerProject (finalAttrs: {
    inherit version;
    pname = "firefly-iii-data-importer";

    src = fetchFromGitHub {
      owner = "firefly-iii";
      repo = "data-importer";
      rev = "v${version}";
      hash = "sha256-tXHj0QsIywiGfm4nEPw6auM0Bw8NoCJdDTH7R59Krjc=";
    };
    vendorHash = "sha256-dziaNdbWAYivH6WBUD5ePfJNK+3VWiNjrlgBoCliVeE=";

    composerStrictValidation = false; # they have some version constraints that are frowned upon apparently

    patches = [
      ./firefly-storage-path.patch
    ];
  })
