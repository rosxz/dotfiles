{
  description = "My simple NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, agenix, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      sshKeys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILW5ZVdVaKMVlau1wp/JGJpdpE6JUxJ07DEYHi9qOLC8 crea@tsukuyomi"
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKtzQZmcfn9DS+s8Wx034OaMHthFXrrG/JQyMl2rLXx u0_a225@localhost"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5qplpxonrKYtW8al56XFjOypAbh49LKH9BdakIb6Ie navi@DESKTOP-EMI1M84"
      ];

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
	        overlay-unstable
	        inputs.agenix.overlay
	      ];
      };

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      systemModules = [ inputs.agenix.nixosModules.age ];

    in
    {
      homeConfigurations = {
	      crea = home-manager.lib.homeManagerConfiguration {
	        # pkgs = nixpkgs.legacyPackages.${system};
    	    inherit pkgs;

	        modules = [
            ./users/crea/home.nix
            {
              home = {
                username = "crea";
                homeDirectory = "/home/crea";
                stateVersion = "22.05";
              };
            }
          ];
	      };
      };

    nixosConfigurations = {
	ebisu = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { inherit sshKeys; };
          modules = [ ./hosts/ebisu/configuration.nix systemModules ];
        };

	tsukuyomi = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { inherit sshKeys; };
          modules = [ ./hosts/tsukuyomi/configuration.nix systemModules ];
        };

	fuujin = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { inherit sshKeys; };
          modules = [ ./hosts/fuujin/configuration.nix systemModules ];
        };
      };
    };
}

