{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  ############ Declaration ###############
  wireSubmodule = types.submodule ({
    name, ...
  }: {
    options = {
      # Circuit information
      pinLabel = mkOption {
        type = types.str;
        description = "Label for pin connected by this wire";
      };
      pinColor = mkOption {
        type = types.str;
        description = "Color for pin connected by this wire";
      };

      # Connection information
      connList = mkOption {
        type = types.listOf types.str;
        default = [];
        description: "Connectors joined by this wire";
      };

      # Electrical details - TODO
      wireGauge = mkOption { type = types.str; };
    };

    config = {};
  });

  ############ Resolution ################
  wireResolve = attrs: {};  # TODO
in {
  ############ Declaration ###############
  options.wires = mkOption {  # TODO
    type = types.attrsOf wireSubmodule;
    description = "Declaration of all extant pin-to-pin connections";
  };
  
  ############ Resolution ################
  options.system.resolvedWires = mkOption {};

  ############ Validation ################
  #config.assertions = {};
}
