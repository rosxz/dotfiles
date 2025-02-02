{...}: self: super: rec {
  inv-sig-helper = super.inv-sig-helper.overrideAttrs (old: {
    version = "0-unstable-2025-01-03";

    src = super.fetchFromGitHub {
      owner = "iv-org";
      repo = "inv_sig_helper";
      rev = "63a8d8166f046c75f05786ebfa7f114cabf0f9a6";
      hash = "sha256-VK+a+1HfESIxH5kj9FfXEuTf6m8kweHgMNJcst2xGzE=";
    };
  });
}
