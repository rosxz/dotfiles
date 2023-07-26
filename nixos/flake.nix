{
  description = "My simple NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/master";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, agenix, impermanence, ... }:
    let
      system = "x86_64-linux";
      inherit (inputs.nixpkgs) lib;
      inherit (builtins) listToAttrs concatLists attrValues attrNames readDir;
      inherit (lib) mapAttrs mapAttrsToList hasSuffix;

      sshKeys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILW5ZVdVaKMVlau1wp/JGJpdpE6JUxJ07DEYHi9qOLC8 crea@tsukuyomi" # Tsukuyomi (HP Homeserver)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon" # Ebisu (ASUS Laptop)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKtzQZmcfn9DS+s8Wx034OaMHthFXrrG/JQyMl2rLXx u0_a225@localhost" # Xiaomi 10
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5qplpxonrKYtW8al56XFjOypAbh49LKH9BdakIb6Ie navi@DESKTOP-EMI1M84" # NAVI Desktop
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7tve12K34nhNgVYZ6VgQBRrJs10v+hClpyzpXTIb/n crea@raijin" # Raijin (RNL)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0Y66xC+lCLENxktcVwGYacISi8A+KEbijg7N+w5HcF crea@ryuujin" # Ryuujin (T490s)
      ];

      overlaysDir = ./overlays;

      myOverlays = mapAttrsToList
        (name: _: import "${overlaysDir}/${name}" { inherit inputs; })
        (readDir overlaysDir);

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      overlays = [
	        overlay-unstable
	        agenix.overlays.default
	    ] ++ myOverlays;

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

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

        specialArgs = { inherit self sshKeys inputs; };
        modules = [ ./hosts/ebisu/configuration.nix agenix.nixosModules.age ];
      };

      ryuujin = lib.nixosSystem {
        inherit system pkgs;

        specialArgs = { inherit self sshKeys inputs; };
        modules = [ ./hosts/ryuujin/configuration.nix agenix.nixosModules.age ];
      };

      tsukuyomi = lib.nixosSystem {
        inherit system pkgs;

        specialArgs = { inherit self sshKeys; };
        modules = [ ./hosts/tsukuyomi/configuration.nix agenix.nixosModules.age ];
      };

      raijin = lib.nixosSystem {
        inherit system pkgs;

        specialArgs = { inherit self sshKeys inputs; };
        modules = [ ./hosts/raijin/configuration.nix agenix.nixosModules.age ];
      };

      hachiman = lib.nixosSystem {
        inherit system pkgs;

        specialArgs = { inherit self sshKeys inputs; };
        modules = [ ./hosts/hachiman/configuration.nix agenix.nixosModules.age impermanence.nixosModule ];
      };
   };
 };
}

