{
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (builtins) attrNames filter length mapAttrs;
  
  # Helpers
  duplicates = xs: xs
    |> lib.groupBy (x: x)
    |> lib.filterAttrs (_: group: length group > 1)
    |> attrNames;

  # Flatten `{ k = [ a b ]; }` into `{ "k[0]" = mkRow "k" 0 a; ... }`
  indexItems = mkRow: getList: attrs: attrs
    |> lib.mapAttrsToList (k: v: getList v 
      |> lib.imap0 (i: item: lib.nameValuePair
        "${k}[${toString i}]" (mkRow k i item)
      ))
    |> lib.concatLists |> lib.listToAttrs;

  validEps = eps: eps
    |> lib.attrValues
    |> filter (e: e.pinFound);
in {
  inherit duplicates;

  # TODO: RFC 145 docstring
  endpoints = resolved: let
    # Maps a connector (name-value pair) to an attrSet of its request names. Each
    # request is mapped to `{ <connName> = true; }`, which is used later to eval-
    # uate pin request satisfaction by checking attrSet membership.
    reqs = mapAttrs (_: c: c.pins
      |> lib.filter (r: r.name != null)
      |> map (r: lib.nameValuePair r.name true)
      |> lib.listToAttrs
    ) resolved.connectors;

    # 
    inspect = id: i: e: let
      parsed = e.conn != null;
      connFound = parsed && reqs ? ${e.conn};
      pinFound = connFound && reqs.${e.conn} ? ${e.pin};
    in {
      inherit parsed connFound pinFound;
      inherit (e) raw conn pin;

      owner = "cores.${id}";
      core  = id;
      index = i;
    };
  in indexItems inspect (c: c.conns) resolved.cores;
  
  # TODO: RFC 145 docstring
  cableCores = resolved: let
    counts = resolved.cores
      |> lib.attrValues
      |> lib.groupBy (c: c.cable)
      |> mapAttrs (_: length);
  in mapAttrs (id: _: {
    owner = "cores.${id}";
    count = counts.${id} or 0;
  }) resolved.cables;
  
  ############# Endpoints ###############
  # TODO: RFC 145 docstring
  coreEnds = resolved: eps: let
    counts = validEps eps
      |> lib.groupBy (e: e.core)
      |> mapAttrs (_: length);
  in mapAttrs (id: c: {
    owner = "cores.${id}";
    total = length c.conns;
    attached = counts.${id} or 0;
  }) resolved.cores;

  # TODO: RFC 145 docstring
  pins = resolved: eps: let
    counts = validEps eps
      |> lib.groupBy (e: "${e.conn}#${e.pin}")
      |> mapAttrs (_: rows: rows
        |> map (e: e.core)
        |> lib.unique
        |> length
      );

    toRow = conn: i: r: {
      inherit (r) name nc;
      inherit conn;
     
      supply = if r.name == null then 0
        else counts."${conn}#${r.name}" or 0;
      owner = "connectors.${conn}";
      index = i;
    };
  in indexItems toRow (c: c.pins) resolved.connectors;

}
