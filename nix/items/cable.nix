{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  ############ Declaration ###############
  cableDeclaration = types.submodule ({
    name, ...
  }: {
    options = {
      #   Circuit information
      # Pin assignments are not part of the cable information
      pinLabels = mkOption {
        type = types.listOf types.str;
        description = "Labels for pins connected by this cable";
      };

      pinColors = mkOption {
        type = types.listOf types.str;
        description = "Colors for pins connected by this cable";
      };

      # Connection information
      connList = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Connectors joined to form a common circuit by this cable.";
      };

      # Material information
    };

    config = {};
  });

  ############ Resolution ################
  resolveCable = attrs: {};  # TODO

  cableResolution = types.submodule ({
    name, ...
  }: {
    options = {};
  });
in {
  ############ Declaration ###############
  options.cables = mkOption {  # TODO
    type = types.attrsOf cableDeclaration;
    description = "Declaration of all extant pin-to-pin connections";
  };
  
  ############ Resolution ################
  options.system.resolvedCables = mkOption {
    type = types.attrsOf cableResolution;
  };

  ############ Validation ################
  #config.assertions = {};
}
