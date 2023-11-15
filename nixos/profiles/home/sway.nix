{ config, pkgs, lib, user, ... }:
let
  lockCommand = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
in
{
  home.packages = [   ];

  wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };

      config = rec {
        modifier = "Mod4";
        terminal = "alacritty";
        menu =
          "wofi -G --allow-images --show drun";

        input = {
          "type:keyboard" = {
            xkb_layout = "pt";
          };

          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };

        keybindings = let
          modifier = "Mod4";
        in lib.mkOptionDefault {
          "${modifier}+Escape" = "exec ${lockCommand}";

          "${modifier}+c" = "kill";

          # Screenshots
          "Print" =
            "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy area";
          "Shift+Print" =
            "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save area /tmp/$(${pkgs.coreutils}/bin/date +'%H:%M:%S.png')";

          # Brightness
          "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -T 0.72";
          "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -T 1.4";

          "XF86AudioRaiseVolume" =
            "exec '${pkgs.pamixer}/bin/pamixer --increase 5'";
          "XF86AudioLowerVolume" =
            "exec '${pkgs.pamixer}/bin/pamixer --decrease 5'";
          "XF86AudioMute" = "exec '${pkgs.pamixer}/bin/pamixer -t'";
          "XF86AudioMicMute" =
            "exec ${pkgs.pamixer}/bin/pamixer --default-source -t";

          # Move to custom workspace
          "${modifier}+t" =
            "exec ${pkgs.sway}/bin/swaymsg workspace $(swaymsg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[].name' | ${pkgs.bemenu}/bin/bemenu -p 'Go to workspace:' )";
          "${modifier}+Shift+t" =
            "exec ${pkgs.sway}/bin/swaymsg move container to workspace $(swaymsg -t get_workspaces | ${pkgs.jq} -r '.[].name' | ${pkgs.bemenu}/bin/bemenu -p 'Move to workspace:')";
        };
        bars = [];
      };

      extraConfig = ''
        output HDMI-A-1 res 2560x1440
        output VGA-1 res 1920x1080 transform 270

        exec dbus-sway-environment
        exec configure-gtk

        exec sww init
        exec sww img $HOME/.background-image
        exec fcitx5
        exec nm-applet --indicator
        exec blueman--aplet
        exec swayidle -w before-sleep $lock
      '';

      extraSessionCommands = ''
        # Needed for GNOME Keyring's SSH integration.
        eval $(/run/wrappers/bin/gnome-keyring-daemon --start --components=ssh)
        export SSH_AUTH_SOCK
        export QT_QPA_PLATFORM=wayland
        export NIXOS_OZONE_WL=1
      '';
    };
}
