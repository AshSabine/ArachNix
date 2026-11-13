{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  # ======================================
  connectorSubmodule = types.submodule ({
    name, ...
  }): {
    options = {
      name = mkOption {};

      socketType = mkOption {};
      socketSubtype = mkOption {};

      pinCount = mkOption { type = types.int; };
      pinsList = mkOption {
        type = types.listOf types.str;
	description = "Automatically populated list of pin names";
      };

      groups = mkOption {
        type = types.listOf types.str;
	description = "Automatically populated list of parent groups";
      };
    };

    config = {

    };
    
    assertions = {

    };
  };


in {
  options.connectors = mkOption {
    type = types.attrsOf connectorSubmodule;
  };
}
