{ config, pkgs, ... }:

{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    page
    zathura
    libqalculate

    patchelf
    devenv
  ];

  programs.man = {
    generateCaches = false;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  xdg.desktopEntries.visual-studio-code = {
    type = "Application";
    name = "Visual Studio Code";
    exec = ''env NIXOS_OZONE_WL=1 code'';
  };
  programs.vscode = {
    enable = true;
    package = with pkgs; unstable.vscode;
    mutableExtensionsDir = true;
    #extensions = with pkgs; [
    #  #vscode-extensions.dracula-theme.theme-dracula
    #  #unstable.vscode-extensions.github.copilot
    #];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
      };
  };

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

  # XDG Defaults
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "text/x-python" = "nvim.desktop";
      "text/*" = "nvim.desktop";
      "application/pdf" = "zathura.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "image/*" = "imv.desktop";
      "video/*" = "mpv.desktop";
      "x-scheme-handler/terminal" = "xfce4-terminal.desktop";
      "inode/directory" = "thunar.desktop";
      # archives / compressed files
      "application/x-7z-compressed" = "xarchiver.desktop";
      "application/x-rar" = "xarchiver.desktop";
      "application/x-xz" = "xarchiver.desktop";
      "application/x-bzip2" = "xarchiver.desktop";
      "application/x-gzip" = "xarchiver.desktop";
      "application/x-tar" = "xarchiver.desktop";
      "application/zip" = "xarchiver.desktop";
      "application/x-iso9660-image" = "xarchiver.desktop";
    };
  };
  xdg.configFile."mimeapps.list".force = true;

  home.file.".config/gtk-3.0/settings.ini".text = ''
  [Settings]
  gtk-cursor-theme-name=Bibata_Ghost
  gtk-menu-images=1
  '';
  home.file.".icons/default".source = "${pkgs.bibata-cursors-translucent}/share/icons/Bibata_Ghost";
}
