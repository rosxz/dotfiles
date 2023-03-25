#xrandr --setprovideroutputsource modesetting NVIDIA-0
#xrandr --auto
#xrandr --dpi 96

# keyboard and keybinds

setxkbmap pt &
xbindkeys &

## Uim config 
#export GTK_IM_MODULE='uim'
#export QT_IM_MODULE='uim'
#uim-xim &
#export XMODIFIERS='@im=uim'
## enable for the gtk(2)/gtk3 uim systray
# uim-toolbar-gtk-systray &

xcompmgr &
dunst &
blueman-applet &
~/.fehbg &
redshift &
flameshot &

# MPD daemon start (if no other user instance exists)
[ ! -s ~/.mpd/pid ] && mpd &
mpdscribble &
fcitx5 -d

exec i3
