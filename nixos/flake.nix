{
  description = "My messy NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence.url = "github:nix-community/impermanence/master";
    nixpkgs-hyprland.url = "github:nixos/nixpkgs/3e2aca0b97ed1c88fa784a368270b4cd223efe1d";
  };

  outputs = { self, ... }@inputs:
  let
    inherit (builtins) listToAttrs concatLists attrValues attrNames readDir;

    system = "x86_64-linux";
    user = "crea";

    lib = inputs.nixpkgs.lib.extend (final: prev: import ./lib {
      inherit inputs pkgs system;
      lib = final;
    });
    overlays = (lib.my.mkOverlays ./overlays) // { agenix = inputs.agenix.overlays.default; };
    pkgs = lib.my.mkPkgs overlays;

    # TODO remove from secrets.nix or here
    sshKeys = {
      user_tsukuyomi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILW5ZVdVaKMVlau1wp/JGJpdpE6JUxJ07DEYHi9qOLC8 crea@tsukuyomi"; # Tsukuyomi (HP Homeserver)
      user_ebisu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon"; # Ebisu (ASUS Laptop)
      user_xiaomi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6yNVUz9RnIFibmEb2cpdrypr2k2KPffMQpmIn0gbHb u0_a243@localhost"; # Xiaomi 10
      user_navi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC36CNRkhRvwygw8dGAHE7ThT5kw2RjuX/X5MzUIfFSU crea@navi"; # NAVI Desktop
      user_raijin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7tve12K34nhNgVYZ6VgQBRrJs10v+hClpyzpXTIb/n crea@raijin"; # Raijin (RNL)
      user_ryuujin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0Y66xC+lCLENxktcVwGYacISi8A+KEbijg7N+w5HcF crea@ryuujin"; # Ryuujin (T490s)
    };

    nixosConfigurations = lib.my.mkHosts {
      modulesDir = ./modules;
      profilesDir = ./profiles;
      hostsDir = ./hosts;
      extraArgs = {
        inherit self sshKeys user system inputs nixosConfigurations;
        root = ./.;
      };
      extraModules = [
        inputs.agenix.nixosModules.age
        # inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        # inputs.programs-sqlite.nixosModules.programs-sqlite
        inputs.nixos-mailserver.nixosModule
      ];
    };
  in
  { inherit overlays nixosConfigurations; };
}

