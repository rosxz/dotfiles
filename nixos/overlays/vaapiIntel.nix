{...}: self: super: rec {
  intel-vaapi-driver = super.intel-vaapi-driver.overrideAttrs (old: { enableHybridCodec = true; });
}
