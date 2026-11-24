{
  description = "ArachNix: Declarative automotive wire harnessing tool";

  nixConfig.extra-experimental-features = [ "pipe-operators" ];

  outputs = { self, nixpkgs, ... }@inputs: let
    forSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
    ];
  in {
    lib = import ./nix { lib = nixpkgs.lib; };

    # TODO: Introduce packages as necessary.
    devShells = forSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      cli = pkgs.writeShellApplication {
        name = "arachnix";
        runtimeInputs = [ pkgs.nix pkgs.jq pkgs.git pkgs.coreutils pkgs.util-linux viz ]
          ++ nixpkgs.lib.optional (pkgs ? wireviz) pkgs.wireviz;
        text = builtins.readFile ./cli/arachnix.sh;
      };

    in {
      default = pkgs.mkShell {
        packages = [ cli viz pkgs.jq ];
        shellHook = ''
          export ARACHNIX_ROOT="$PWD"
          echo "arachnix: eval | check | viz (arachnix help)"
        '';
      };
    }); 
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
