{
  lib,
  spec,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  ############ Declaration ###############
  cableDeclaration = types.submodule { options = {
    bom   = mkOption { type = spec.bom.type; default = {}; };
    props = mkOption { type = types.attrsOf types.anything; default = {}; };
  }; };

  ############ Resolution ################
  cableResolution = types.submodule { options = {
    id    = mkOption { type = types.str; };
    bom   = mkOption { type = spec.bom.type; };
    props = mkOption { type = types.attrsOf types.anything; };
  }; };
in {
  ############ Declaration ###############
  options.cables = mkOption {
    type = types.attrsOf cableDeclaration;
    default = {};
  };
  
  ############ Resolution ################
  options.resolved.cables = mkOption {
    type = types.attrsOf cableResolution;
    readOnly = true;
  };

  config.resolved.cables = lib.mapAttrs (id: c: {
    inherit id;
    inherit (c) bom props;
  }) config.cables;
}
