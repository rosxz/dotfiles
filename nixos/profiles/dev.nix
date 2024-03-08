{ self, config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [
  ];

  environment.systemPackages = [
    pkgs.unstable.julia-bin
  ];
}
