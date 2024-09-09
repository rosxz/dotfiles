{config, lib, ...}:
with lib; {
  options.modules.labels = {
    type = mkOption {
      type = types.nullOr types.str;
      description = "Type of host";
      default = "";
      example = "vm";
    };
  };

  config = {
    assertions = [
      {
        assertion = config.modules.labels.type != "";
        message = "Host '${config.networking.hostName}' must have a type label";
      }
    ];
  };
}
