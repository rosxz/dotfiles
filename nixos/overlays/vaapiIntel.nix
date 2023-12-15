self: super: rec {
  vaapiIntel = super.vaapiIntel.overrideAttrs (old: { enableHybridCodec = true; });
}
