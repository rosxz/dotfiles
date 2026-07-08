{ config, lib, pkgs, ... }:

# Icons reference:
# - https://github.com/walkxcode/dashboard-icons/tree/main/svg
# - https://thehomelab.wiki/books/helpful-tools-resources/page/icons-for-self-hosted-dashboards
let domain = "dash.moniz.pt";
    settings = {
      title = "App dashboard";
      subtitle = "Homer";
      icon = "fas fa-skull-crossbones";
      header = true;
      footer = ''
        <p>Created with <span class="has-text-danger">❤️</span> with <a href="https://bulma.io/">bulma</a>, <a href="https://vuejs.org/">vuejs</a> & <a href="https://fontawesome.com/">font awesome</a> // Fork me on <a href="https://github.com/bastienwirtz/homer"><i class="fab fa-github-alt"></i></a></p>
      '';
      columns = "3";
      connectivityCheck = true;

      proxy.useCredentials = false;

      defaults = {
        layout = "columns";
        colorTheme = "dark";
      };

      theme = "default";

      colors = {
        light = {
          "highlight-primary" = "#bd93f9";
          "highlight-secondary" = "#ff79c6";
          "highlight-hover" = "#ff92d0";
          background = "#282a36";
          "card-background" = "#44475a";
          text = "#f8f8f2";
          "text-header" = "#f8f8f2";
          "text-title" = "#f8f8f2";
          "text-subtitle" = "#f8f8f2";
          "card-shadow" = "rgba(0, 0, 0, 0.45)";
          link = "#8be9fd";
          "link-hover" = "#50fa7b";
        };

        dark = {
          "highlight-primary" = "#7a5ea8";
          "highlight-secondary" = "#a24b78";
          "highlight-hover" = "#b5628a";
          background = "#282a36";
          "card-background" = "#44475a";
          text = "#f8f8f2";
          "text-header" = "#f8f8f2";
          "text-title" = "#f8f8f2";
          "text-subtitle" = "#f8f8f2";
          "card-shadow" = "rgba(0, 0, 0, 0.45)";
          link = "#8be9fd";
          "link-hover" = "#50fa7b";
        };
      };

      services = [
        {
          name = "General";
          icon = "fas fa-user-circle";
          items = [
            {
              name = "MonizCloud";
              icon = "fas fa-cloud";
              subtitle = "Nextcloud instance";
              url = "https://cloud.moniz.pt";
            }
            {
              name = "Firefly";
              icon = "fas fa-coins";
              subtitle = "Firefly instance";
              url = "https://fire.moniz.pt";
            }
            {
              name = "Syncthing";
              icon = "fas fa-floppy-disk";
              url = "https://sync.moniz.pt";
            }
          ];
        }
        {
          name = "Entertainment";
          icon = "fas fa-tv";
          items = [
            {
              name = "Jellyfin";
              icon = "fas fa-headphones";
              subtitle = "Music, Movies and Shows";
              keywords = "self hosted music movies shows";
              url = "https://media.moniz.pt";
              target = "_blank";
            }
            {
              name = "Invidious";
              icon = "fab fa-youtube";
              subtitle = "Privacy-minded youtube proxy";
              keywords = "self hosted youtube";
              url = "https://inv.moniz.pt";
            }
            {
              name = "Calibre";
              icon = "fas fa-book";
              subtitle = "Book collection manager";
              url = "https://calibre.moniz.pt";
            }
          ];
        }
        {
          name = "Torrenting";
          icon = "fas fa-magnet";
          items = [
            {
              name = "Transmission";
              icon = "fas fa-satellite-dish";
              subtitle = "Torrent web interface";
              url = "https://transmission.moniz.pt";
              keywords = "torrent";
            }
            {
              name = "Flood";
              icon = "fas fa-water";
              subtitle = "Torrent web interface";
              url = "https://flood.moniz.pt";
              keywords = "torrent";
            }
            {
              name = "Soulseekd";
              icon = "fas fa-headphones";
              url = "https://slskd.moniz.pt";
            }
          ];
        }
        {
          name = "Arrs";
          icon = "fas fa-heartbeat";
          items = [
            {
              name = "Dispatcharr";
              icon = "fas fa-tv";
              subtitle = "Manage IPTV streams, EPG data, and VOD content.";
              url = "https://dispatcharr.moniz.pt";
            }
            {
              name = "Bazarr";
              icon = "fas fa-closed-captioning";
              subtitle = "Subtitles manager";
              keywords = "self hosted subtitles";
              url = "https://bazarr.moniz.pt";
            }
            {
              name = "Prowlarr";
              icon = "fas fa-filter";
              subtitle = "Arr manager";
              keywords = "self hosted subtitles";
              url = "https://prowlarr.moniz.pt";
            }
          ];
        }
        {
          name = "Monitoring";
          icon = "fa-brands fa-watchman-monitoring";
          items = [
            {
              name = "Grafana";
              icon = "fas fa-chart-column";
              subtitle = "Monitoring dashboards and alerts";
              url = "https://grafana.moniz.pt";
            }
            {
              name = "Router - Reixida";
              icon = "fas fa-network-wired";
              url = "https://router.moniz.pt";
            }
          ];
        }
      ];
    };
in {
  #virtualisation.oci-containers.containers.homer = {
  #  image = "b4bz/homer:latest";
  #  autoStart = true;
  #  ports = [ "127.0.0.1:8089:8080" ];
  #  volumes = [ "/var/lib/homer/assets:/www/assets" ];
  #  user = "1001";
  #};
  services.homer = {
    enable = true;
    settings = settings;
    virtualHost = {
      inherit domain;
      nginx.enable = true;
    };
  };

  services.nginx.virtualHosts.${domain} = {
    default = true;
    forceSSL = true;
    useACMEHost = "moniz.pt";
  };
}
