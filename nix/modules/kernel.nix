{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  # TODO: write RFC 145 docstring for what this is doing. In short this turns
  # an assertion / item pair into an attrSet containing error state info.
  toResult = a: item: {
    inherit (a) id severity stage;
    inherit (item) path;
    msg = a.check item.value;
    ignored = a.severity == "warning"
      && lib.elem a.id config.ignored;
  };

  # TODO: RFC 145 docstring. Unsure if stageAsserts should be inlined here. I
  # have left it alone because it should be done exactly once when assertions 
  # are declare, then accessed via an O(1) lookup, but lib.groupBy does nothing
  # that couldn't be done by just indexing directly.
  stageAsserts = lib.groupBy (a: a.stage) config.asserts;
  runPhase = stage: phaseIn: let
    selector = a: a.select phaseIn |> map (toResult a);
  in lib.concatMap selector (stageAsserts.${stage} or []);
 
  # Precompute results
  checked = builtins.mapAttrs runPhase config.phases;
in {
  options = {
    ignored   = mkOption { type = types.listOf types.str; default = []; };
    asserts   = mkOption { type = types.listOf types.raw; default = []; };

    phases  = mkOption { type = types.attrsOf types.raw; default = {}; };
    results   = mkOption { type = types.attrsOf (types.listOf types.raw); readOnly = true; };
    stats     = mkOption { type = types.attrs; readOnly = true; }; 
  };

  config.results = checked |> lib.mapAttrs (_: rs: 
    lib.filter (r: r.msg != null) rs);

  config.stats = {
    checked = checked
      |> lib.attrValues 
      |> lib.concatLists
      |> builtins.length;

    failed = config.results
      |> lib.attrValues
      |> lib.concatLists
      |> lib.count (r: !r.ignored);
  };
}
