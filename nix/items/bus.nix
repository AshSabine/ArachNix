{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  ############ Declaration ###############
  busSubmodule = types.submodule ({
    name, ...
  }: {
    options = {
      pinNames = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Pins carried by this wire";
      };
      pinColors = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Colors by pin in order";
      };
    };

    config = {};
  });
in {
  ############ Declaration ###############

  ############ Resolution ################

  ############ Validation ################
}
