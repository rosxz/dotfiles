{...}: final: prev: {
    protontricks =
      (prev.protontricks.overrideAttrs {
        src = final.fetchFromGitHub {
          owner = "Matoking";
          repo = "protontricks";
          rev = "f7b1fa33b0438dbd72f7222703f8442e40edc510";
          hash = "sha256-t794WEMJx/JNX3gTMHfgquFWB7yXkleW07+QURm1NPM=";
        };
      }).override {
        vdf = final.python312Packages.vdf.overrideAttrs {
          src = final.fetchFromGitHub {
            owner = "Matoking";
            repo = "vdf";
            rev = "981cad270c2558aeb8eccaf42cfcf9fabbbed199";
            hash = "sha256-OPonFrYrEFYtx0T2hvSYXl/idsm0iDPwqlnm1KbTPIo=";
          };
        };
      };
}
