{ pkgs, ... }: {
  home.packages = [ pkgs.gammastep ];

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 38.6;
    longitude = -9.1;
    temperature.day = 4500;
    temperature.night = 2500;
  };
}
