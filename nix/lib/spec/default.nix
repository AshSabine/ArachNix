{
  lib,
  data
}: {
  cable = import ./cable.nix { inherit lib; };
  color = import ./color.nix { inherit lib data; };
  conn  = import ./conn.nix  { inherit lib; };
  core  = import ./core.nix  { inherit lib; };
}
