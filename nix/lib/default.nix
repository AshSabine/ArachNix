{
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  data = import ./data.nix { inherit lib; };
  rule = import ./rule.nix { inherit lib; };
}
