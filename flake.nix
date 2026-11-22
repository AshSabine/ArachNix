{
  description = "ArachNix: Declarative automotive wire harnessing tool";

  nixConfig.extra-experimental-features = [ "pipe-operators" ];

  outputs = { self, nixpkgs, ... }@inputs: let
    forSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
    ];
  in {
    # TODO: Introduce packages as necessary.
    packages = forSystems (system: {});

    devShells = forSystems (system: let
      pkgs = nixpkgs.legacyPackages.system;
      arachnix-cli = import ./sh { inherit pkgs; };
    in { default = pkgs.mkShell { packages = [ arachnix-cli ]; }; }); 
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
