{ config, pkgs, ... }:

{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    page
    unstable.kdenlive
    zathura
    man-pages
    # libreoffice-qt
    krita
    xournalpp
    libqalculate

    patchelf
    # easyrpg-player

    # godot_4
    # aseprite-unfree
    # blender
  ];

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

  programs.ssh = {
    enable = true;
    extraConfig = ''
# Assume hosts without fqdn come from RNL
CanonicalizeHostname yes
CanonicalDomains rnl.tecnico.ulisboa.pt
CanonicalizeMaxDots 0

#Match originalhost lab*,!lab*.rnl.tecnico.ulisboa.pt
#  HostName dolly.rnl.tecnico.ulisboa.pt
#  User root
#  RemoteCommand ssh %n
#  ForwardAgent no
#  RequestTTY yes

Match canonical host="*.rnl.tecnico.ulisboa.pt"
  User root
  ServerAliveInterval 60

Host *.rnl.tecnico.ulisboa.pt *.rnl.ist.utl.pt
  User root
  ServerAliveInterval 60''; # TODO: put this in a proper place
  };

  home.file.".config/gtk-3.0/settings.ini".text = ''
  [Settings]
  gtk-cursor-theme-name=Bibata_Ghost
  '';
  home.file.".icons/default".source = "${pkgs.bibata-cursors-translucent}/share/icons/Bibata_Ghost";
}
