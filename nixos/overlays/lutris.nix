{...}: self: super: rec {
  lutris-unwrapped = super.lutris-unwrapped.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "rosxz";
      repo = "lutris";
      rev = "0c93c2fad546e684346c8fe3179ab797d5e033f3";
      sha256 = "sha256-1DI/cOIIYQhvArCx659rvnzWqZKK1Qhmv96Uq5mCJ3E=";
    };
  });
}
