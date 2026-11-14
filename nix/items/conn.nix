{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  ############ Declaration ###############
  connDeclaration = types.submodule ({
    name, ...
  }: {
    options = {
      connType = mkOption { type = types.str; };    # JST, Molex, etc.
      connSubtype = mkOption { type = types.str; }; # male/andro/female etc.

      pinCount = mkOption { type = types.int; };    # maximum pins for this connector
      wishlist = mkOption {
        type = types.attrs;
      };
    };

    config = {};
  });

  ############ Resolution ################
  resolveConn = path: attrs:
    if attrs ? pinCount then {
      "${lib.last path}" = attrs // { groups = lib.init path; };
    } else builtins.foldl' (acc: name: let
      child = resolveConn (path ++ [name]) attrs.${name};
      collisions = builtins.intersectAttrs acc child;
    in if collisions != {} then
      throw "ERROR: Duplicate connector names detected across groups: ${builtins.toJSON (builtins.attrNames collisions)}"
    else acc // child) {} (builtins.attrNames attrs);
    
  connResolution = types.submodule ({
    name, ...
  }: {
    options = {
      # Exists for enforced disambiguation during validation step
      connName = mkOption { type = types.str; };
      
      connType = mkOption { type = types.str; };    # JST, Molex, etc.
      connSubtype = mkOption { type = types.str; }; # male/andro/female etc.

      pinCount = mkOption { type = types.int; };
      pinNames = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Automatically populated list of pin names/labels";
      };

      groups = mkOption {
        type = types.listOf types.str;
        description = "Automatically populated list of parent groups";
      };
    };

    config = {};
  });
in {
  ############ Declaration ###############
  options.connectors = mkOption {
    type = types.attrs; default = {};
    description = "Hierarchical declaration of connectors.";
  };

  ############ Resolution ################
  options.system.resolvedConnectors = mkOption {
    type = types.attrsOf connResolution;
    readOnly = true; internal = true;
  };

  config.system.resolvedConnectors = resolveConn [] config.connectors;
  
  ############ Validation ################
  #config.assertions = {};
}
