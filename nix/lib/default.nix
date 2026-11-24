{
  lib,
}: let
  std  = import ./std.nix  { inherit lib; };
  net  = import ./net.nix  { inherit lib; };
  data = import ./data.nix { inherit lib; };
  spec = import ./spec { inherit lib data; };
  rule = import ./rule.nix { inherit lib; };
in {
  inherit std net data spec rule;
}
