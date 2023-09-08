{ config, pkgs, user, lib, ... }:
{
  services.syncthing = {
    enable = true;
    user = "${user}"; #TODO: in the future this probably shouldnt be :grimace:
    systemService = true;
    openDefaultPorts = true;
    dataDir = "/home/${user}/Documents";    # Default folder for new synced folders
    configDir = "/home/${user}/.config/syncthing";   # Folder for Syncthing's settings and keys
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
