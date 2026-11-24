{
  description = "ArachNix: Declarative automotive wire harnessing tool";

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
        runtimeInputs = [ pkgs.nix pkgs.jq pkgs.git ];
        text = builtins.readFile ./cli/arachnix.sh;
      };
    in {
      default = pkgs.mkShell {
        packages = [ cli pkgs.jq ];
        shellHook = ''
          export ARACHNIX_ROOT="$PWD"
          echo "arachnix: eval | check (arachnix help)"
        '';
      };
    }); 
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
