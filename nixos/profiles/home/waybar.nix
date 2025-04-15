{ config, pkgs, lib, user, ... }:
{
  programs.waybar.enable = true;
  programs.waybar.style = ''
@define-color bg #282a36;
@define-color fg #f8f8f2;
@define-color fg-unfocused #6272a4;

@define-color bg-alt #181A20;
@define-color fg-alt #A8A8A8;

@define-color bg-active #44475a;
@define-color fg-active #ff79c6;
@define-color bg-inactive #282a36;
@define-color fg-inactive #bd93f9;

/* styles for main constructs
 *
 * must be combined with bg_{main,alt,dim}
 */
@define-color red #FF8059;
@define-color green #44BC44;
@define-color yellow #EECC00;
@define-color blue #29AEFF;
@define-color magenta #FEACD0;
@define-color cyan #00D3D0;

/* for elements that should draw attention to themselves
 *
 * must be combined with bg_main
 */
@define-color red-intense #FB6859;
@define-color green-intense #00FC50;
@define-color yellow-intense #FFDD00;
@define-color blue-intense #00A2FF;
@define-color magenta-intense #FF8BD4;
@define-color cyan-intense #30FFC0;

/* for background elements that should be visible and distinguishable
 *
 * must be combined with fg_main
 */
@define-color red-intense-bg #A4202A;
@define-color green-intense-bg #006800;
@define-color yellow-intense-bg #874900;
@define-color blue-intense-bg #2A40B8;
@define-color magenta-intense-bg #7042A2;
@define-color cyan-intense-bg #005F88;

@keyframes blink-alert {
	to {
		background-color: @red-intense-bg;
		font-weight: bold;
	}
}

@keyframes blink-warn {
	to {
		background-color: @yellow-intense-bg;
		font-weight: bold;
	}
}

window {
	border: none;
	font-size: 15px;
	min-height: 0;
	font-family: "Font Awesome", "Fira Code";
}

* {
	border-radius: 0;
}

window#waybar {
	background-color: rgba(40, 42, 54, 0.8);
	/*border-bottom: 3px solid @bg-alt;*/
	color: @fg;
	transition-property: background-color;
	transition-duration: .5s;
}

window#waybar.hidden {
	opacity: 0.2;
}

/*
window#waybar.empty {
	background-color: transparent;
}
window#waybar.solo {
	background-color: #FFFFFF;
}
*/

window#waybar.termite {
}

window#waybar.chromium {
	border: none;
}

#workspaces button {
	padding: 0 5px;
	margin: 0 2px;
	min-width: 1.25em;
	color: @fg;
	border-bottom: 3px solid @bg-inactive;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
#workspaces button:hover {
	background: rgba(0, 0, 0, 0.2);
	box-shadow: inherit;
}

#workspaces button.focused {
	background-color: @bg-active;
	border-bottom-color: @yellow-intense-bg;
}

#workspaces button.urgent {
	background-color: @red-intense-bg;
}

#mode {
	background-color: @yellow-intense-bg;
}

#clock,
#battery,
#cpu,
#memory,
#temperature,
#backlight,
#network,
#pulseaudio,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#mpd {
	padding: 0 10px;
	margin: 0 4px;
}

#clock {
	border-bottom: 3px solid @blue-intense-bg;
}

#battery {
	border-bottom: 3px solid @magenta-intense-bg;
}


@keyframes pre-warn {
	0% {
		background-color: @bg;
		color: @fg;
	}
	2.5% {
		background-color: @yellow-intense-bg;
		color: #000000;
	}
	5% {
		background-color: @bg;
		color: @fg;
	}
}

#battery.pre-warning:not(.charging) {
	animation-name: pre-warn;
	animation-duration: 20s;
	animation-timing-function: ease-in-out;
	animation-iteration-count: infinite;
	animation-direction: alternate;
}

#battery.warning:not(.charging) {
	animation-name: blink-warn;
	animation-duration: 1s;
	animation-timing-function: ease-in-out;
	animation-iteration-count: infinite;
	animation-direction: alternate;
}

#battery.critical:not(.charging) {
	animation-name: blink-alert;
	animation-duration: 0.5s;
	animation-timing-function: ease-in-out;
	animation-iteration-count: infinite;
	animation-direction: alternate;
}

@keyframes charging-animation {
	0% {
		background-color: @bg;
	}
	5% {
		background-color: @bg-alt;
	}
	10% {
		background-color: @bg;
	}
}

#battery.charging {
	animation-name: charging-animation;
	animation-duration: 60s;
	animation-iteration-count: infinite;
}

#cpu {
	border-bottom: 3px solid @green-intense-bg;
}

#memory {
	border-bottom: 3px solid @magenta-intense-bg;
}

/*
#backlight {
	border-bottom: 3px solid @fg;
}

#network {
	border-bottom: 3px solid @fg;
}

#network.disconnected {
	background-color: @bg-alt;
}

#pulseaudio {
	border-bottom: 3px solid @fg;
}

#pulseaudio.muted {
	background-color: @bg-alt;
	color: @fg-alt;
}

#custom-media {
	border-bottom: 3px solid @fg;
	min-width: 100px;
}

#custom-media.custom-spotify {
	border-bottom-color: @fg-alt;
}

#custom-media.custom-vlc {
	border-bottom-color: @fg-alt;
}*/

#temperature {
	border-bottom: 3px solid @green-intense-bg;
}

#temperature.critical {
	animation-name: blink-warn;
	animation-duration: 1s;
	animation-timing-function: ease-in-out;
	animation-iteration-count: infinite;
	animation-direction: alternate;
	border-bottom-color: @yellow-intense-bg;
}

#tray {
	border-bottom: 3px solid @bg-alt;
	font-family: "Font Awesome", "Noto Sans";
}

#idle_inhibitor {
	border-bottom: 3px solid @bg-inactive;
	color: @fg-inactive;
	transition-property: background-color, color, border-bottom-color;
	transition-duration: 0.5s;
}

#idle_inhibitor.activated {
	background-color: @bg-active;
	border-bottom-color: @bg-active;
	color: @fg-active;
}

/*
#mpd {
	border-bottom: 3px solid #66CC99;
	color: #2a5c45;
}

#mpd.disconnected {
	background-color: #f53c3c;
}

#mpd.stopped {
	background-color: #90b1b1;
}

#mpd.paused {
	background-color: #51a37a;
}*/
  '';
  programs.waybar.systemd.enable = true;
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "bottom";
      height = 34;
      modules-left = ["clock" "sway/mode" "sway/workspaces"];
      modules-center = [];
      modules-right = ["pulseaudio" "backlight" "cpu" "temperature#cpu" "temperature#gpu" "memory" "battery" "tray"];

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };
	    "sway/mode"= {
	    	"format"= "{}";
	    };
	    "idle_inhibitor"= {
	    	"format"= "{icon}";
	    	"format-icons"= {
	    		"activated"= "";
	    		"deactivated"= "";
	    	};
	    };
	    "tray"= {
	    	# "icon-size"= 21,
	    	"spacing"= 10;
	    };
	    "clock"= {
	    	"interval"= 5;
	    	"format"= "🕒 {:%a %d/%b %H:%M}";
	    	"format-alt"= "🕒 {:%a %F %T}";
	    	"tooltip"= false;
	    };
	    "cpu"= {
	    	"format"= " {usage}%";
	    	"tooltip"= false;
	    };
	    "memory"= {
	    	"format"= " {used:4.2f}/{total:4.2f} GiB";
	    	"on-click"= "alacritty --command htop";
	    };
	    "temperature#cpu"= {
	    	# "thermal-zone"= 2,
	    	"hwmon-path"= "/sys/class/hwmon/hwmon4/temp1_input";
	    	"critical-threshold"= 80;
	    	# "format-critical"= "{temperatureC}°C {icon}";
	    	"format"= "{icon} {temperatureC}°C";
	    	"format-icons"= ["" "" "" "" ""];
	    };
	    "temperature#gpu"= {
	    	# "thermal-zone"= 2,
	    	"hwmon-path"= "/sys/class/hwmon/hwmon6/temp1_input";
	    	"critical-threshold"= 80;
	    	# "format-critical"= "{temperatureC}°C {icon}",
	    	"format"= "{icon} {temperatureC}°C";
	    	"format-icons"= ["" "" "" "" ""];
	    };
	    "backlight"= {
	    	# "device"= "acpi_video1",
	    	"format"= "{icon} {percent}%";
	    	"format-icons"= ["🔆"];
	    };
	    "battery"= {
	    	"interval"= 2;
	    	"states"= {
	    		# "good"= 95,
	    		"pre-warning"= 30;
	    		"warning"= 20;
	    		"critical"= 10;
	    	};
	    	"format"= "{icon} {capacity}%";
	    	"format-charging"= "{icon} {capacity}%";
	    	"format-plugged"= "{icon} {capacity}%";
	    	"format-alt"= "{icon} {time}";
	    	# "format-good"= "", // An empty format will hide the module
	    	# "format-full"= "",
	    	"format-icons"= ["" "" "" "" ""];
	    };
	    "network"= {
	    	# "interface"= "wlp2*", // (Optional) To force the use of this interface
	    	"format-wifi"= " {essid} ({signalStrength}%)";
	    	"format-ethernet"= " {ifname}: {ipaddr}/{cidr}";
	    	"format-linked"= " {ifname} (No IP)";
	    	"format-disconnected"= "⚠ Disconnected";
	    	"tooltip-format"= "{ifname}: {ipaddr}/{cidr}";
	    	"on-click"= "nm-connection-editor";
	    };
	    "pulseaudio"= {
	    	# "scroll-step"= 1, // %, can be a float
	    	"format"= "{icon} {volume}% {format_source}";
	    	"format-bluetooth"= "{icon} {volume}% {format_source}";
	    	"format-bluetooth-muted"= "{icon} 🔇 {format_source}";
	    	"format-muted"= "🔇 {format_source}";
	    	"format-source"= " {volume}%";
	    	"format-source-muted"= "";
	    	"format-icons"= {
	    		"headphones"= "";
	    		"handsfree"= "";
	    		"headset"= "";
	    		"phone"= "";
	    		"portable"= "";
	    		"car"= "";
	    		"default"= ["" "" ""];
	    	};
	    	"on-click"= "pavucontrol";
	    };
    };
  };
}
