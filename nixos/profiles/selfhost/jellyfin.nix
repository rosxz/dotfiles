{ pkgs, lib,config, ... }:
{
  # 1. enable vaapi on OS-level
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  services.jellyfin = {
    enable = true;
    # package = with pkgs; unstable.jellyfin;
    openFirewall = true;
  };
  users.users.jellyfin = {
    extraGroups = [ "media" "render" "video" ];
  };

  # 2. override default hardening measure from NixOS - this is default since 22.05
  systemd.services.jellyfin.serviceConfig.PrivateDevices = lib.mkForce false;
}
