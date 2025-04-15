{...}: self: super: rec {
  lutris-unwrapped = super.lutris-unwrapped.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "rosxz";
      repo = "lutris";
      rev = "750eb7432b9a945ac18fc129ca635bc9fad853c2";
      sha256 = "sha256-1DI/cOIIYQhvArCx659rvnzWqZKK1Qhmv96Uq5mCJ3E=";
    };
  });
}
