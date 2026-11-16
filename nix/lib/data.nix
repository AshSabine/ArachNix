{
  lib,
  ...
}: let
  inherit (builtins) fromJSON readDir;
in {
  readJSON = name: fromJSON (readDir "../json/${name}.json");
}
