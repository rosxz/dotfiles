{
  description = "My epic nixos flake config with sunglasses";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
  let
    system = "x86_64-linux";
    
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      
      # Main system
      nixos = lib.nixosSystem {
        inherit system;

	modules = [
	  ({config, pkgs, ...}: { nixpkgs.overlays = [ overlay-unstable ]; })
	  ./hosts/configuration.nix
	];
      };
    };
  };
}
