{
  lib,
  net,
  rule,
  ...
}: let
  inherit (rule) mkAssert failIf;
  inherit (builtins) length;

  conns = rule.all "connectors";
  pins  = rule.all "pins";
in { config.asserts = [
  ############ Resolve ############
  (mkAssert "conn-name-collision" "error" "resolve" {
    select = conns;
    check  = c: failIf (builtins.length c.connPaths > 1)
      "connector name '${c.connName}' is declared more than once: ${lib.concatStringsSep ", " c.connPaths}";
  })
  (mkAssert "conn-pin-overflow" "error" "resolve" {
    select = conns;
    check  = c: let n = builtins.length c.pins; in failIf (n > c.pinCount)
      "${toString n} pins declared on a ${toString c.pinCount}-pin connector";
  })
  (mkAssert "conn-pin-duplicate" "error" "resolve" {
    select = conns;
    check  = c: let
      dups = c.pins |> map (q: q.name) |> lib.filter (n: n != null) |> net.duplicates;
    in failIf (dups != []) "duplicate pin request(s): ${lib.concatStringsSep ", " dups}";
  })
  (mkAssert "conn-pin-unnamed" "error" "resolve" {
    select = pins;
    check  = p: failIf (p.name == null && !p.nc) "pin request has no name and is not marked N/C";
  })

  ############ Validate ############
  (mkAssert "conn-pin-unspecified" "warning" "validate" {
    select = conns;
    check  = c: let n = c.pinCount - builtins.length c.pins; in
      failIf (n > 0) "${toString n} pin(s) neither requested nor marked N/C";
  })
  (mkAssert "pin-unsatisfied" "warning" "validate" {
    select = pins;
    check  = p: failIf (!p.nc && p.name != null && p.supply == 0)
      "pin '${p.name}' is unsatisfied (no core connected)";
  })
  (mkAssert "pin-oversatisfied" "error" "validate" {
    select = pins;
    check  = p: failIf (!p.nc && p.name != null && p.supply > 1)
      "pin '${p.name}' is oversatisfied (${toString p.supply} cores connected)";
  })
  (mkAssert "pin-nc-connected" "error" "validate" {
    select = pins;
    check  = p: failIf (p.nc && p.supply > 0)
      "pin '${p.name or "<unnamed>"}' is marked N/C but has ${toString p.supply} core(s) connected";
  })
]; }
