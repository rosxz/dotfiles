{ config, pkgs, lib, self, sshKeys, ... }:

let
  cfg = config.modules.distributed_builds;

  localConfig = {
    age.secrets.builder-key = {
      file = "${self}/secrets/builder-pass.age";
    };

    nix = {
      distributedBuilds = true;
      buildMachines = map (server: {
        sshUser = "builder";
        sshKey = config.age.secrets.builder-key.file;
        hostName = server;
        system = "x86_64-linux";
        maxJobs = 1;
        supportedFeatures = [ "kvm" "big-parallel" ];
      }) cfg.servers;
    };
  };

  remoteConfig = {
    # Adds dumb builder user, accessible only through ssh, host keys of clients
    users.users.builder = {
      hashedPassword = "*"; # Disable password login
      isNormalUser = true;
      createHome = false;
      openssh.authorizedKeys.keys = [ sshKeys.builder ];
      group = "builders";
    };
    users.groups.builders = {};
    # Allows builder to run nix-build
    nix.settings = {
      trusted-users = [ "builder" ];
    };
  };
in
with lib;
{
  options.modules.distributed_builds = {
    enable = mkEnableOption "distributed_builds";

    type = mkOption {
      type = types.str;
      description = "Either remote (build server) or local (build client)";
      default = "local";
      example = "remote";
    };

    servers = mkOption {
      type = types.listOf types.str;
      description = "List of build servers to reach (only used if type is local)";
      default = [];
      example = [ "build1" "build2" ];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { assertions = [
        {
          assertion = lib.assertOneOf "distributed_builds type" cfg.type ["remote" "local"];
          message = "distributed_builds type must be one of remote or local";
        }
    ];}

    (mkIf (cfg.type == "local") localConfig)
    (mkIf (cfg.type == "remote") remoteConfig)
  ]);
}
