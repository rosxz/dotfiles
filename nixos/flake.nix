{
  description = "My messy NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";
    nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/master";
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

      sshKeys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILW5ZVdVaKMVlau1wp/JGJpdpE6JUxJ07DEYHi9qOLC8 crea@tsukuyomi" # Tsukuyomi (HP Homeserver)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon" # Ebisu (ASUS Laptop)
  # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKtzQZmcfn9DS+s8Wx034OaMHthFXrrG/JQyMl2rLXx u0_a225@localhost" # Xiaomi 10
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6yNVUz9RnIFibmEb2cpdrypr2k2KPffMQpmIn0gbHb u0_a243@localhost" # Xiaomi 10
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5qplpxonrKYtW8al56XFjOypAbh49LKH9BdakIb6Ie navi@DESKTOP-EMI1M84" # NAVI Desktop
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7tve12K34nhNgVYZ6VgQBRrJs10v+hClpyzpXTIb/n crea@raijin" # Raijin (RNL)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0Y66xC+lCLENxktcVwGYacISi8A+KEbijg7N+w5HcF crea@ryuujin" # Ryuujin (T490s)
      ];

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
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        # inputs.programs-sqlite.nixosModules.programs-sqlite
        inputs.nixos-mailserver.nixosModule
      ];
    };
  in
  { inherit nixosConfigurations; };
}

