{ pkgs, lib,config, ... }:
{
  services.polaris = {
    enable = true;
    openFirewall = true;
    extraGroups = [ "media" ];
    settings = ''
# Array of locations Polaris should scan to find music files
[[mount_dirs]]
# Directory to scan
source = "/mnt/Storage/Shared/Music"
# User-facing name for this directory (must be unique)
name = "My Music 🎧️"

# Array of user accounts who can connect to the Polaris server
[[users]]
# Username for login
name = "admin"
# If true, user will have access to all settings in the web UI
admin = true
# Plain text password for this user. Will be ignored if hashed_password is set. Polaris will never write to this field. For each user, at least one of initial_password and hashed_password must be set.
initial_password = "feijoes_e_batatas"
    '';
  };
}
