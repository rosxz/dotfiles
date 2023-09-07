{ pkgs, config, lib, ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      allow-images = true;
      allow-markup = true;
      gtk_dark = true;
      key_expand = "L_ALT";
    };
    style =
    ''
      * {
          font-family: "TeX Gyre Adventor";
      }

      #input{
          color: white;
          padding: 0.25em;
      }
    '';
  };
}
