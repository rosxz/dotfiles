{ config, pkgs, lib, ... }:

{
  services.syncthing = {
    enable = true;
    user = "crea";
    systemService = true;
    openDefaultPorts = true;
    dataDir = "/home/crea/Documents";    # Default folder for new synced folders
    configDir = "/home/crea/.config/syncthing";   # Folder for Syncthing's settings and keys
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
