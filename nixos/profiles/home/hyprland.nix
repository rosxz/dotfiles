{ config, pkgs, lib, toggles, wallpaper, ... }:
let
  terminal = "${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal";
  fileManager = "${pkgs.xfce.thunar}/bin/thunar";
  lockCommand = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
  menu = "${pkgs.wofi}/bin/wofi -G --allow-images --show drun";
  apprun = "${pkgs.wofi}/bin/wofi -G --show run";
  print_area = "${pkgs.sway-contrib.grimshot}/bin/grimshot --notify savecopy area /tmp/$(date +'%H:%M:%S.png')";
  print_active = "${pkgs.sway-contrib.grimshot}/bin/grimshot --notify savecopy active /tmp/$(date +'%H:%M:%S.png')";
in
{
  home.packages = [   ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      #preload = [ wallpaper ];
      #wallpaper = [ ", ${wallpaper}" ];
    };
  };
  services.hyprpolkitagent.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      # Monitor
      monitor = ", highres, auto, 2";
      xwayland = {
        force_zero_scaling = true;
      };
      # Programs
      env = [
        # HiDPI
        "GDK_SCALE,2"
        "XCURSOR_SIZE,32"
        "QT_QPA_PLATFORM,wayland"
        "NIXOS_OZONE_WL,1"
      ];
      # Autostart
      exec-once = [
        "dbus-sway-environment"
        "configure-gtk"
        "waybar"
        "fcitx5 &"
        "nm-applet --indicator"
        "blueman-applet"
        "safeeyes"
      ];
      debug.full_cm_proto = true; # FOR GAMESCOPE
      # Styling
      general = {
        "$mod" = "SUPER";
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false;
        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
        layout = "dwindle";
      };
      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration = {
        rounding = 10;
        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
      	inactive_opacity = 0.8; # 0.0 - 1.0, 0.0 means no opacity
        #dim_inactive = true
      	#dim_strength = 0.25 # 0.0 - 1.0, 0.0 means no dimming
        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };
      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {
        enabled = true;
        # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # You probably want this
      };
      misc = {
        force_default_wallpaper = 0; # 0 or 1 dp disable anime mascot wallpapers
        disable_hyprland_logo = true; # Set to true to disable the Hyprland logo / anime girl
      };
      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        kb_layout = "pt";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
          natural_scroll = false;
        };
      };
      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      #gestures.workspace_swipe = false;
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more per-device config
      # BINDINGS
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      bind =
        [
          ", PAUSE, exec, hyprfreeze -a"
          # Scroll through existing workspaces with mainMod + scroll
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          "$mod, Return, exec, ${terminal}"
          "$mod, C, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, ${fileManager}"
          "$mod, Space, togglefloating,"
          "$mod, D, exec, ${menu}"
          "$mod, X, exec, ${apprun}"
          "$mod, P, pseudo, # dwindle"
          "$mod, J, togglesplit, # dwindle"
          "$mod, F, fullscreen, # fullscreen"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"
          # Example special workspace (scratchpad)
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
          # Utilities
          "$mod, Escape, exec, ${lockCommand}"
          "$mod SHIFT, Escape, exec, systemctl suspend"
          ", Print, exec, ${print_active}"
          "SHIFT, Print, exec, ${print_area}"
          ", XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -T 0.72"
          ", XF86MonBrightnessUp, exec, ${pkgs.light}/bin/light -T 1.4"
          ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer --increase 5"
          ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer --decrease 5"
          ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t"
          ", XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (i:
              let ws = i+1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            10)
        );
      windowrulev2 = "suppressevent maximize, class:.*"; # You'll probably like this.
    };
  };
}
