{ lib, ... }:

let
  domain = "poke.moniz.pt";
  invidiousApi = "https://inv.moniz.pt/api/v1";
in
{
  modules.services.poke = {
    enable = lib.mkDefault true;
    pUrl = "https://${domain}";
    invidiousApi = invidiousApi;
    settings = {
      tubeApi = "https://inner-api.poketube.fun/api/";
      media_proxy = "https://image-proxy.poketube.fun";
      videourl = "https://eu-proxy.poketube.fun";
      email_main_url = "https://email-server.poketube.fun";
      mastodon_client_url = "https://social.poketube.fun";
      libreoffice_online_url = "https://office.poketube.fun";
      banner = "welcome to poke!";
      t_url = "https://t.poketube.fun/";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    useACMEHost = "moniz.pt";
    locations."/".proxyPass = "http://127.0.0.1:6003";
  };
}