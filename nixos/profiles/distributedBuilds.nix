{ config, lib, pkgs, ... }:

{
  # Only use on encrypted systems.
  nix = {
    distributedBuilds = true;
    buildMachines = [{
      hostName = "raijin.rnl.tecnico.ulisboa.pt";
      sshUser = "crea";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      systems = [ "x86_64-linux" ];
      maxJobs = 10;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
