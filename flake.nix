{
  description = "ArachNix: Declarative automotive wire harnessing tool";

  outputs = { self, nixpkgs, ... }@inputs: let
    forSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
    ];

    
  in {
    packages = forSystems (system:

    );

    devShells = forSystems (system:
      
    );
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
