{
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  # TODO  
  cableSpec = types.submodule ({
    name, ...
  }: {
    options = {};
  });

}
