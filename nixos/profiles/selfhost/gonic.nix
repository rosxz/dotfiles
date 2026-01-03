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
      music-path = "/storage-pool/Shared/Music";
      playlists-path = "/storage-pool/Shared/Gonic/Playlists";
      podcast-path = "/storage-pool/Shared/Gonic/Podcasts";
      listen-addr = "127.0.0.1:4747";
      #db-path = "/storage-pool/Shared/Gonic/gonic.db";
      multi-value-artist = "multi";
      multi-value-album-artist = "multi";
    };
  };
}
