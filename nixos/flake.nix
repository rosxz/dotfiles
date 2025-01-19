{
  description = "My messy NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence.url = "github:nix-community/impermanence/master"; # cool homeserver/vps thing
    # nixpkgs-hyprland.url = "github:nixos/nixpkgs/3e2aca0b97ed1c88fa784a368270b4cd223efe1d"; # for sunshine
    nixpkgs-transmission405.url = "github:nixos/nixpkgs/bf16ab6fce7e0e6e463685723116548c94754bb3"; # last transsmission version without announce bug
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

    customPins = { unstable = inputs.nixpkgs-unstable; transmission405 = inputs.nixpkgs-transmission405; }; # need instancing a new nixpkgs
    overlays = (lib.my.mkOverlays ./overlays) // { agenix = inputs.agenix.overlays.default; }; # legacyPackages, follows nixpkgs
    pkgs = lib.my.mkPkgs overlays customPins;

    sshKeys = import ./keys.nix;

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
        # inputs.nixos-mailserver.nixosModule
      ];
    };
  in
  { inherit overlays nixosConfigurations; };
}

