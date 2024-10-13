{config, lib, ...}:
with lib; {
  options.modules.labels = {
    type = mkOption {
      type = types.nullOr types.str;
      description = "Type of host";
      default = "";
      example = "vm";
    };
    display = mkOption rec {
      type = types.str;
      description = "Wayland or Xorg display";
      default = "wayland";
      example = default;
    };
  };

  config = {
    assertions = [
      {
        assertion = config.modules.labels.type != "";
        message = "Host '${config.networking.hostName}' must have a type label";
      }
      {
        assertion = lib.assertOneOf "display type" config.modules.labels.display ["wayland" "xorg"];
        message = "Host '${config.networking.hostname}' display type must be one of wayland or xorg";
      }
    ];
  };
}
