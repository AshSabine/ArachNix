{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  
  cableSpec = types.submodule ({
    name, ...
  }: {
    options = {};
    config = {};
  });

}
