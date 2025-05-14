{ config, pkgs, lib, toggles, ... }:
let
  lockCommand = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
in
{
  home.packages = [   ];

  wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
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
        output = {
          DP-1 = {
            scale = "2";
          };
        };

        keybindings = let
          modifier = "Mod4";
          apprun = "wofi -G --show run";
          #recordScript = pkgs.writeTextFile {
          #  name = "recordScript";
          #  text = ''
          #    #!/usr/bin/env bash
          #    ${pkgs.sway}/bin/swaymsg Record microphone?
          #  '';
          #  executable = true;
          #};
        in lib.mkOptionDefault {
          "${modifier}+Escape" = "exec ${lockCommand}";
          "${modifier}+Shift+Escape" = "exec systemctl suspend";
          "${modifier}+c" = "kill";
          "${modifier}+x" = "exec ${apprun}";

          # Screenshots
          "Print" =
            "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify savecopy active /tmp/$(${pkgs.coreutils}/bin/date +'%H:%M:%S.png')";
          "Shift+Print" =
            "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify savecopy area /tmp/$(${pkgs.coreutils}/bin/date +'%H:%M:%S.png')";
          "${modifier}+Print" =
            "exec alacritty -t ScreenRecorder -e ''${pkgs.wf-recorder}/bin/wf-recorder -a -m webm -c libvpx -C libopus -f /tmp/$(${pkgs.coreutils}/bin/date +'%H:%M:%S.webm')''";
          "${modifier}+Shift+Print" =
            "exec alacritty -t ScreenRecorder -e ''${pkgs.wf-recorder}/bin/wf-recorder -g $(${pkgs.slurp}/bin/slurp) -a -m webm -c libvpx -C libvorbis -f /tmp/$(${pkgs.coreutils}/bin/date +'%H:%M:%S.webm')''";

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
        exec dbus-sway-environment
        exec configure-gtk

        exec fcitx5
        exec nm-applet --indicator
        exec swayidle -w before-sleep $lock
        exec blueman-applet
        exec ${pkgs.wluma}/bin/wluma
      ''; # TODO test home.username ? says its undefined

      extraSessionCommands = ''
        # Needed for GNOME Keyring's SSH integration.
        eval $(/run/wrappers/bin/gnome-keyring-daemon --start --components=ssh)
        export SSH_AUTH_SOCK
        export QT_QPA_PLATFORM=wayland
        export NIXOS_OZONE_WL=1
      '';
    };
}
