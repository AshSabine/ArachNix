{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  # ======================================
  socketSubmodule = types.submodule ({
    name, ...
  }: {
    options = {
      socketName = mkOption { type = types.str; };
      
      socketType = mkOption { type = types.str; };
      socketSubtype = mkOption { type = types.str; };

      pinCount = mkOption { type = types.int; };
      pinNames = mkOption {
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
  });

  flattenSockets = path: attrs:
    if attrs ? pinCount then {
      "${lib.last path}" = attrs // { groups = lib.init path; };
    } else builtins.foldl' (acc: name: let
      child = flattenSockets (path ++ [name]) attrs.${name};
      collisions = builtins.intersectAttrs acc child;
    in if collisions != {} then
      throw "ERROR: Duplicate socket names detected across groups: ${builtins.toJSON (builtins.attrNames collisions)}"
    else acc // child) {} (builtins.attrNames attrs);
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
  
  config.assertions = {};
}
