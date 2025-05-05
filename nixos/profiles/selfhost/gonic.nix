{ pkgs, lib,config, ... }:
{
  users.users.gonic = {
    isSystemUser = true;
    group = "gonic";
  };
  users.groups.gonic = {};
  services.gonic = {
    enable = true;
    settings = {
      music-path = "/mnt/Storage/Shared/Music";
      playlists-path = "/mnt/Storage/Shared/Gonic/Playlists";
      podcast-path = "/mnt/Storage/Shared/Gonic/Podcasts";
      listen-addr = "127.0.0.1:4747";
      #db-path = "/mnt/Storage/Shared/Gonic/gonic.db";
      multi-value-artist = "multi";
      multi-value-album-artist = "multi";
    };
  };
}
