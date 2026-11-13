{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  wireSubmodule = types.submodule ({
    name, ...
  }): {
    options = {

    };

    config = {};

    assertions = {};
  }
in {

}
