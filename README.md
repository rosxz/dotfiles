# .navifiles
Dotfiles for my common Arch Linux setup.

- [.navifiles](#.navifiles)
  - [How-to](#how-to-install)
  - [Essential Packages](#essential-packages)
  - [Optional Packages](#optional-packages)
  - [Manual configurations](#manual-configurations)
  - [Anki](#anki)
    - [Essential addons](#essential-addons)
    - [Optional addons](#optional-addons)
    - [Configuration](#configuration)

## How to install

## Essential Packages
| Name			 | Description			  | Repository	  |
| :--------------------- | :----------------------------- | :-------------|
| stow | Easily install config files | APKG |
| xorg-server, xorg-xinit | X11 Server | APKG |
| lightdm
| zsh | Z shell | APKG |
| cronie | Crontab | APKG |
| alacritty | Terminal emulator | APKG |
| neovim | Text editor | APKG |
| vim-plug | Plugin manager for nvim | AUR |
| gnome-keyring | Keyring | APKG |
| dunst | Notifications | APKG |
| rofi | Dmenu replacement | APKG |
| htop | Task manager | APKG |
| neofetch | swag | APKG |
| [flameshot](https://github.com/flameshot-org/flameshot) | Screenshot utility | APKG | 
| feh | Image viewer and wallpaper tool | APKG |
| thunar, gvfs, xarchiver, thunar-archive-plugin, thunar-media-tags-plugin, thunar-volman, tumbler, gvfs-mtp, gvfs-smb | File manager | APKG |
| thunar-shares-plugin | File manager | AUR |
| redshift | Blue-light filter, eye-strain reduction | APKG |
| blueman | Bluetooth management | APKG |
| pipewire, wireplumber, pipewire-alsa, pipewire-pulse, pavucontrol | Audio | APKG |
| mpd	| Music playback daemon | APKG |
| mpdscribble | Scrobble music to online databases | AUR |
| ncmpcpp | CLI music player | APKG |
| playerctl | Media Player controller | APKG |
| spotify, [spotify-adblock](https://github.com/abba23/spotify-adblock-linux)| Block spotify ads :dance:| AUR |
| [powerlevel-10k](https://github.com/romkatv/powerlevel10k), [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/) | CLI swag | AUR |
| noto-fonts, noto-fonts-emoji, noto-fonts-extra | Noto fonts | APKG |
| ttf-fira-code, ttf-joypixels, ttf-font-awesome | Neat fonts with emojis n stuff | APKG |
| ttf-meslo-nerd-font-powerlevel10k | Oh-My-Zsh Font | AUR |
| zathura, zathura-pdf-mupdf | PDF Reader | APKG |
| xf86-input-wacom | Wacom xorg drivers | APKG |
| exa | Cool ls replacement | APKG |
| arc-gtk-theme | Arc themes | APKG |
| adobe-source-han-sans-jp-fonts, adobe-source-han-serif-jp-fonts, otf-ipafont, ttf-hanazono | Japanese fonts | APKG |
| ttf-monapo | Japanese fonts | AUR |
| fcitx5-im | IME | APKG |
| fcitx5-mozc-ut, fcitx5-skin-arc | IME | AUR |
| anki-bin | SRS Learning Tool | AUR |
| brave-bin | Brave browser | AUR |
| discord | VoIP and chat clients | APKG |

## Optional Packages

### Virtualization
| Name			| Description		| Repository	|
| :---------------------| :---------------------| :-------------|
| virt-manager, libvirt, virt-viewer | VM Manager | APKG	|
| qemu-desktop		| Virtual System Emulation | APKG |
| dnsmasq, bridge-utils, openbsd-netcat, vde2	  | Networking | APKG |
| dkms			| Dynamic kernel module management | APKG |

### Entertainment
| Name			| Description		| Repository	|
| :---------------------| :---------------------| :-------------|
| ani-cli | Stream anime from the cli to mpv | AUR |
| calibre | Ebook manager | APKG | 

### Misc
| Name			| Description		| Repository	|
| :---------------------| :---------------------| :-------------|
| syncthing	| Sync folders between devices | APKG |
| element-desktop | VoIP and chat clients | APKG |

[comment]: # (TODO: add weeb packages and other stuff, add links to rest of packages)

## Manual configurations

## Anki

### Essential Addons

| Name 		| Description | Anki-Web	|
| :-------------| :-----------| :-------------|
| AnkiConnect 	| Connecting to Yomichan | 2055492159 |
| AJT Furigana 	| Automatically add furigana to cards | 1344485230 |
| AJT Pitch Accent | Automatically add pitch-accent notation to cards | 1225470483 |
| PassFail 2	| Remove bloated answer buttons | 876946123 |
| RefoldEase 	| Reset cards ease in bulk 	| 819023663 |

### Optional Addons

| Name		| Description | Anki-Web 	|
| :-------------| :-----------| :---------------|
| Adjust Sound Volume | | 2123044452 |
| Kanji Grid 	| Render pages with learned kanji | 909972618 |

### Configuration
