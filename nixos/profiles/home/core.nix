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
    extensions = with pkgs; [
      vscode-extensions.dracula-theme.theme-dracula
      unstable.vscode-extensions.github.copilot
    ];
  };

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

  programs.ssh.enable = true;

  home.file.".config/gtk-3.0/settings.ini".text = ''
  [Settings]
  gtk-cursor-theme-name=Bibata_Ghost
  gtk-menu-images=1
  '';
  home.file.".icons/default".source = "${pkgs.bibata-cursors-translucent}/share/icons/Bibata_Ghost";
}
