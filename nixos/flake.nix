{
  description = "My simple NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      sshKeys = [
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon"
      ];

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
	overlays = [ overlay-unstable ];
      };
      
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

    in
    {
      homeConfigurations = {
	crea = home-manager.lib.homeManagerConfiguration {
	  # When switching to 22.11, just use these two lines:
	  # pkgs = nixpkgs.legacyPackages.${system};
	  # modules = [ ./users/crea/home.nix ];
	  inherit system pkgs;

	  username = "crea";
	  homeDirectory = "/home/crea";
	  configuration = {
	    imports = [ ./users/crea/home.nix ];
	  };
	};
      };

      nixosConfigurations = {
	ebisu = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { inherit sshKeys; };
          modules = [ ./hosts/ebisu/configuration.nix ];
        };
	
	tsukuyomi = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { inherit sshKeys; };
          modules = [ ./hosts/tsukuyomi/configuration.nix ];
        };
      };
    };
}

