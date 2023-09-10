{ config, pkgs, lib, ... }:

let
  cfg = config.modules.services.hd-idle;
in
with lib;
{
  options.modules.services.hd-idle = {
    enable = mkEnableOption "hd-idle";

    drives = mkOption {
      type = types.listOf types.str;
      default = [];
      description = lib.mdDoc ''
        A list of drive device names to be affected
        by the service. Leave unset to target all
        external drives..
      '';
      example = [ "sda sdb" ];
    };

    package = mkOption {
      type = types.package;
      default = pkgs.hd-idle;
      defaultText = "pkgs.hd-idle";
      description = ''
        The hd-idle package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hd-idle = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "hd-idle system service";
      serviceConfig =
        let
          drives = config.modules.services.hd-idle.drives;
          ids = if drives != [] then lib.concatStrings (lib.intersperse " " ([ " -a" ] ++ drives)) else "";
        in
      {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = lib.concatStrings ["${cfg.package}/bin/hd-idle -i 1800" "${ids}"];
      };
    };
  };
}
