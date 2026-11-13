{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  # ======================================
  socketSubmodule = types.submodule ({
    name, ...
  }): {
    options = {
      socketType = mkOption { type = types.str; };
      socketSubtype = mkOption { type = types.str; };

      pinCount = mkOption { type = types.int; };
      pinsList = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Automatically populated list of pin names";
      };

      groups = mkOption {
        type = types.listOf types.str;
        description = "Automatically populated list of parent groups";
      };
    };

    config = {};
    assertions = {};
  };

  flattenSockets = path: attrs:
    if attrs ? pinCount then {
      "${builtins.concatStringsSep "." path}" = attrs // { groups = lib.init path; };
    } else builtins.foldl'
      (acc: name: acc // flattenSockets (path ++ [name]) attrs.${name})
      {} (builtins.attrNames attrs);
in {
  options.sockets = mkOption {
    type = types.attrs;
    default = {};
    description = "Hierarchical declaration of connectors.";
  };

  options.system.resolvedSockets = mkOption {
    type = types.attrsOf socketSubmodule;
    readOnly = true; internal = true;
  };

  config.system.resolvedSockets = flattenSockets [] config.sockets;
}
