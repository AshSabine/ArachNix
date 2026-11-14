{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  
  

  coreSpec = types.submodule ({
    name, ...
  }: {
    options = {};
    config = {};
  });

}
