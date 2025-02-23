{ config, inputs, pkgs, user, profiles, lib, ... }:

{
  modules.labels.display = "wayland";

  imports = [
    "${inputs.nixpkgs-unstable}/services/x11/desktop-managers/xfce.nix"
  ];

  services.xserver.desktopManager.xfce = {
    enable = true;
    enableWaylandSession = true;
    enableScreensaver = true;
  };

  environment.systemPackages = with pkgs; [
  ];
}
