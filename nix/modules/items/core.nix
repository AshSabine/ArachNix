{
  lib,
  spec,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (builtins) length;

  ############# Declaration #############
  coreDeclaration = types.submodule { options = {
    name  = mkOption { type = types.nullOr types.str; default = null; };
    color = mkOption { type = types.nullOr spec.color.type; default = null; };

    conns = mkOption { type = types.listOf spec.pin.type; default = []; };
    root  = mkOption { type = types.nullOr spec.pin.type; default = null; };
  }; };

  ############# Resolution ##############
  # Reflection of the coreDeclaration with identification data
  coreResolution = types.submodule { options = {
    id    = mkOption { type = types.str; };  # "<cable>.<name or index>"
    cable = mkOption { type = types.str; };  # Parent cable for this core
    index = mkOption { type = types.int; };  # Numeric index within cable 

    # Reflected properties
    name  = mkOption { type = types.nullOr types.str; default = null; };
    color = mkOption { type = types.nullOr spec.color.type; default = null; }; 

    conns = mkOption { type = types.listOf spec.pin.type; default = []; };
    root  = mkOption { type = types.nullOr spec.pin.type; default = null; };
  }; };

  # Repeated names inside one cable would create overlapping identifiers.
  # Duplicates fall back to name~index and are reported by core-name-collision.
  resolveCable = cable: c: let
    counts = c.cores
      |> lib.filter (core: core.name != null)
      |> lib.groupBy (core: core.name)
      |> builtins.mapAttrs (_: group: length group);
    
    localID = i: core: 
      if core.name == null then toString i
      else if counts.${core.name} == 1 then core.name
      else "${core.name}~${toString i}";

    toResolved = i: core: let
      id = "${cable}.${localID i core}";
    in lib.nameValuePair id {
      inherit id cable;
      inherit (core) name color conns root;
      index = i;
    };
  in c.cores |> lib.imap0 toResolved;
in {
  ############# Declaration #############
  options.cables = let
    coreSubmodule = types.submodule { options.cores = mkOption {
      type = types.listOf coreDeclaration;
      default = [];
    }; };
  in mkOption { type = types.attrsOf coreSubmodule; };

  ############# Resolution ##############
  options.resolved.cores = mkOption {
    type = types.attrsOf coreResolution;
    readOnly = true;
  };
  
  config.resolved.cores = config.cables
    |> lib.mapAttrsToList resolveCable
    |> lib.concatLists |> lib.listToAttrs;
}
