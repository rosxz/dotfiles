{...}: self: super: rec {
  bibata-cursors-translucent = super.bibata-cursors-translucent.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "rosxz";
      repo = "Bibata_Cursor_Translucent";
      rev = "6b33097a687d20ecd8160b0e4a39aa74c40f43ee";
      sha256 = "sha256-q4VQ91ZMGvAsu9q/Hf6oHqjbdQ26auV/zHfxmExEHQA=";
    };
  });
}
