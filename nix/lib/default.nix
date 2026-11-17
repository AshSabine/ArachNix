{
  lib,
}: let
  data = import ./data.nix { inherit lib; };
  rule = import ./rule.nix { inherit lib; };
  spec = import ./spec { inherit lib data; };
in {
  inherit data rule spec;
}
