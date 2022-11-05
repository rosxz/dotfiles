{ config, pkgs, lib, ... }:

{
  services.syncthing = {
    enable = true;
    user = "crea";
    systemService = true;
    openDefaultPorts = true;
    dataDir = "/home/crea/syncthing";
    configDir = "/home/crea/.config/syncthing";
    overrideFolders = false;
    overrideDevices = false;
    guiAddress = "0.0.0.0:8384";
    extraOptions = {
      gui = {
        theme = "dark";
      };
    };
  };

}
