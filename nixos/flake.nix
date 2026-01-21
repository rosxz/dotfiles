{
  description = "My messy NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";                     #<<
    pin-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11"; #<<
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    musnix.url = "github:musnix/musnix/master";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    pin-transmission405.url = "github:nixos/nixpkgs/bf16ab6fce7e0e6e463685723116548c94754bb3"; # last transsmission version without announce bug
  };

  outputs = { self, ... }@inputs:
  let
    system = "x86_64-linux";
    user = "crea";

    lib = inputs.nixpkgs.lib.extend (final: prev: import ./lib {
      inherit inputs pkgs system;
      lib = final;
    });

    # If need instancing a new nixpkgs; prepend pin- to name
    # Otherwise, insert here (pin follows nixpkgs | legacyPackages)
    overlays = (lib.my.mkOverlays ./overlays) // {
      agenix = inputs.agenix.overlays.default;
    };
    pkgs = lib.my.mkPkgs overlays (lib.my.mkCustomPins inputs);

    sshKeys = import ./keys.nix;

    nixosConfigurations = lib.my.mkHosts {
      modulesDir = ./modules;
      profilesDir = ./profiles;
      hostsDir = ./hosts;
      # for importing unstable modules iirc
      specialArgs.unstable = inputs.pin-unstable;
      extraArgs = {
        inherit self sshKeys user system inputs nixosConfigurations;
        root = ./.;
      };
      extraModules = [
        inputs.musnix.nixosModules.musnix
        inputs.agenix.nixosModules.age
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  in
  { inherit overlays nixosConfigurations; };
}

