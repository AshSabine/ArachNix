{
  lib,
  spec,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (builtins) filter mapAttrs;
 
  # Issues raised before this phase, grouped by owner object.
  issues = (config.results.resolve ++ config.results.validate)
    |> filter (x: !x.ignored)
    |> lib.groupBy (x: x.path);

  issuesOf = owner: map (x: {
    inherit (x) id path severity stage msg;
  }) (issues.${owner} or []);

  ########### Color Validation ##########
  neutral     = "#9E9E9E";
  placeholder = "#FF00FF";

  invalid  = col: col != null && lib.any (t: t.ty == "ERR") col.tokens;
  hexCodes = col: 
    if col == null then [ neutral ]
    else if invalid col then [ placeholder ]
    else map (t: t.hex) col.tokens;

  ############ Pin Validation ###########
  pinsByConn = config.netlist.pins
    |> builtins.attrValues
    |> lib.groupBy (p: p.conn);

  pinState = pin: if pin.nc then "nc"
    else if pin.supply > 1  then "oversatisfied"
    else if pin.supply == 1 then "satisfied"
    else "unsatisfied";

  ########## Cable Validation ############
  allConns = builtins.attrNames config.resolved.connectors;
  coresByCable = config.resolved.cores
    |> builtins.attrValues
    |> lib.groupBy (c: c.cable);
in {
  options.output = mkOption { type = types.attrs; readOnly = true; };

  config.output = {
    conns = mapAttrs (name: c: {
      inherit (c) connName groups connType pinCount;

      pins = pinsByConn.${name} or []
        |> lib.sort (a: b: a.index < b.index)
        |> map (p: {
          inherit (p) name nc supply; # TODO supply is wrong
          state = pinState p;
        });

      issues = issuesOf "connectors.${name}";
    }) config.resolved.connectors;
    
    cables = mapAttrs (id: cb: let
      cores = coresByCable.${id} or []
        |> lib.sort (a: b: a.index < b.index);
      coreIds = map (x: x.id) cores;
    in {
      inherit id;

      conns = cores 
        |> lib.concatMap (x: x.conns)
        |> lib.catAttrs "conn"
        |> (cs: lib.intersectLists cs allConns);

      cores = map (x: x.id) cores;
      coreCount = builtins.length cores;

      issues = issuesOf "cables.${id}";
      dangling = lib.any (i:
        config.output.cores.${i}.dangling
      ) coreIds;
      empty = (cores == []);
    }) config.resolved.cables;

    cores = mapAttrs (id: c: let
      end = config.netlist.coreEnds.${id};
    in {
      inherit id;
      inherit (c) cable root;
    
      conns = map (e: e.raw) c.conns;
    
      color = hexCodes c.color;
      colorFallback = invalid c.color;

      issues = issuesOf "cores.${id}";
      dangling = end.total < 2 || end.attached < end.total;
    }) config.resolved.cores;

    # Recursively fetch the already-evaluated bool
    dangling = config.output.cores
      |> lib.filterAttrs (_: c: c.dangling)
      |> builtins.attrNames;
  };

  config.phases.output = config.output;
}
