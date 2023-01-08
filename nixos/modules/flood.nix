{ config, pkgs, lib, ... }:

let
  cfg = config.services.flood;
in
with lib;
{
  options.services.flood = {
    enable = mkEnableOption "flood";

    user = mkOption {
      default = "flood";
      type = types.str;
      description = ''
        User account under which flood runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "rtorrent";
      description = ''
        Group under which flood runs.
        Flood needs to have the correct permissions if accessing rtorrent through the socket.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.flood;
      defaultText = "pkgs.flood";
      description = ''
        The flood package to use.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = ''
        Address flood binds to
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = ''
        The flood web port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the port in <option>services.flood.port</option>.
      '';
    };

    rpcSocket = mkOption {
      type = types.str;
      readOnly = true;
      default = "/run/rtorrent/rpc.sock";
      description = ''
        RPC socket path.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/flood";
      description = ''
        The directory where flood stores its data files.
      '';
    };

    downloadDir = mkOption {
      type = types.str;
      default = config.services.rtorrent.downloadDir;
      description = ''
        Root directory for downloaded files
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "flood") {
      flood = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        home = cfg.dataDir;
        description = "flood Daemon user";
        isSystemUser = true;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall) [ cfg.port ];

    systemd.services.flood = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "flood system service";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "simple";
        Restart = "on-failure";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/flood --auth none --rundir ${cfg.dataDir} --host ${cfg.host} --port ${toString cfg.port} --rtsocket ${cfg.rpcSocket} --allowedpath ${cfg.downloadDir} --allowedpath /var/lib";
      };
    };

    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0755 ${cfg.user} ${cfg.group} -" ];
  };
}
