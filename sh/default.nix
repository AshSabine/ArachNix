{
  pkgs
}: let
  inherit (pkgs.lib) attrValues;
in pkgs.writeShellApplication {
  name = "arachnix";
  runtimeInputs = (attrValues {
    inherit (pkgs) nix jq coreutils;
  });
  text = builtins.readFile ./arachnix.sh;
}
