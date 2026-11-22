{
  lib,
  data
}: {
  bom   = import ./bom.nix   { inherit lib; };
  pin   = import ./pin.nix   { inherit lib; };
  conn  = import ./conn.nix  { inherit lib; };
  color = import ./color.nix { inherit lib data; };
}
