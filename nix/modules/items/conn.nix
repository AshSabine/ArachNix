{
  lib,
  spec,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  ############ Declaration ###############
  connDeclaration = types.submodule { options = {
    bom      = mkOption { type = spec.bom.type; default = {}; };
    props    = mkOption { type = types.attrsOf types.anything; default = {}; };
    connType = mkOption { type = types.nullOr types.str; default = null; }; # male/andro/female etc.

    pinCount = mkOption { type = types.int; }; # maximum pins for this connector
    pins = mkOption { type = types.listOf spec.conn.request; default = []; };

  }; };

  ############ Resolution ################
  connResolution = types.submodule { options = {
    # Exists for enforced disambiguation during validation step
    connName  = mkOption { type = types.str; };
    connPaths = mkOption { type = types.listOf types.str; };
    groups    = mkOption { type = types.listOf types.str; };
    
    # Reflected properties
    bom       = mkOption { type = spec.bom.type; default = {}; };
    props     = mkOption { type = types.attrsOf types.anything; default = {}; };
    connType  = mkOption { type = types.nullOr types.str; default = null; }; # male/andro/female etc.

    pinCount  = mkOption { type = types.int; }; # maximum pin count
    pins  = mkOption { type = types.listOf spec.conn.request; };
  }; };
  
  # Resolution helper.
  resolveConn = connName: leaves: let
    connPaths = leaves |> map (l:
      lib.concatStringsSep "."
      (l.groups ++ [ l.name ])
    );
    
    first = lib.head leaves;
    pins = first.value.pins;
  in {
    inherit connName connPaths pins;
    inherit (first) groups;
    inherit (first.value) bom props connType pinCount;
  };
in {
  ############ Declaration ###############
  options.connectors = mkOption {
    type = spec.conn.mkTree {
      leaf = connDeclaration;
      isLeaf = spec.conn.isLeaf;
      leafName = "connector";
    };
    default = {};
    description = "Hierarchical declaration of connectors.";
  };

  ############ Resolution ################
  options.resolved.connectors = mkOption {
    type = types.attrsOf connResolution;
    readOnly = true;
  };

  config.resolved.connectors = config.connectors
    |> spec.conn.denest []
    |> lib.groupBy (l: l.name)
    |> lib.mapAttrs resolveConn;
}
