{ inputs, pkgs, lib, system, ... }:
let
  rakeLeaves =
    /* *
       Synopsis: rakeLeaves _path_

       Recursively collect the nix files of _path_ into attrs.

       Output Format:
       An attribute set where all `.nix` files and directories with `default.nix` in them
       are mapped to keys that are either the file with .nix stripped or the folder name.
       All other directories are recursed further into nested attribute sets with the same format.

       Example file structure:
       ```
       ./core/default.nix
       ./base.nix
       ./main/dev.nix
       ./main/os/default.nix
       ```

       Example output:
       ```
       {
       core = ./core;
       base = base.nix;
       main = {
       dev = ./main/dev.nix;
       os = ./main/os;
       };
       }
       ```
       *
    */
    dirPath:
    let
      seive = file: type:
        # Only rake `.nix` files or directories
        (type == "regular" && lib.hasSuffix ".nix" file)
        || (type == "directory");

      collect = file: type: {
        name = lib.removeSuffix ".nix" file;
        value = let path = dirPath + "/${file}";
        in if (type == "regular") || (type == "directory"
          && builtins.pathExists (path + "/default.nix")) then
          path
          # recurse on directories that don't contain a `default.nix`
        else
          rakeLeaves path;
      };

      files = lib.filterAttrs seive (builtins.readDir dirPath);
    in lib.filterAttrs (n: v: v != { }) (lib.mapAttrs' collect files);
in {
  inherit rakeLeaves;

  mkPkgs = overlays: customPins:
    let args = { inherit system; config.allowUnfree = true; config.permittedInsecurePackages = [ ]; };
    in
    import inputs.nixpkgs (args // {
      overlays = lib.attrValues overlays
      ++ lib.mapAttrsToList (name: flake: (final: prev: { ${name} = import flake args;})) customPins;
    });

  mkOverlays = overlaysDir:
    lib.mapAttrsRecursive
    (_: module: import module {inherit rakeLeaves inputs;})
    (lib.my.rakeLeaves overlaysDir);

  mkProfiles = profilesDir:
    (map
      (p: ({ self, config, pkgs, user, lib, inputs, profiles, ... } @ args: {
        config = lib.mkIf
          (builtins.elem (lib.removeSuffix ".nix" (builtins.baseNameOf p)) config.profiles)
          (import p args);
      }))
      (lib.my.listModulesRecursive profilesDir)
    ) ++ [
      ({ options, lib, ... }: {
        options.profiles = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      })
    ];

  mkHost = name: { modulesDir, profilesDir, config, specialArgs, extraArgs, extraModules, ... } @ args: lib.nixosSystem {
    inherit system pkgs lib;
    specialArgs =
    let profiles = rakeLeaves profilesDir; in {
      inherit profiles extraArgs;
    } // args.specialArgs; # Perchance a bit uggy, should touch up later!!
    modules = [
      config
      { networking.hostName = lib.mkForce name; }
      { _module.args = extraArgs; }
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
        };
      }
    ] ++ lib.my.listModulesRecursive modulesDir ++ extraModules;
  };

  mkHosts = args: lib.mapAttrs
    (name: config: lib.my.mkHost name config)
    (lib.mapAttrs
      (name: _: {
        config = "${args.hostsDir}/${name}/configuration.nix";
      } // args)
      (lib.filterAttrs
        (p: _: !(lib.hasPrefix "_" p))
        (builtins.readDir args.hostsDir)));
}
