{
  lib,
  net,
  rule,
  ...
}: let
  inherit (rule) mkAssert failIf require;

  cores     = rule.all "cores";
  endpoints = rule.all "endpoints";
  count     = c: builtins.length c.conns;
in { config.asserts = [
  ############ Resolve ############
  (mkAssert "endpoint-unparseable" "error" "resolve" {
    select = endpoints;
    check  = e: failIf (e.status == "NULL") "unparseable endpoint '${e.raw}' (expected conn#pin)";
  })
  (mkAssert "endpoint-unknown-conn" "error" "resolve" {
    select = endpoints;
    check  = e: failIf (e.status == "NO CONN") "unknown connector '${e.conn}'";
  })
  (mkAssert "endpoint-unknown-pin" "error" "resolve" {
    select = endpoints;
    check  = e: failIf (e.status == "NO PIN")
      "pin '${e.pin}' is not declared on connector '${e.conn}'";
  })

  (mkAssert "core-duplicate-endpoint" "error" "resolve" {
    select = cores;
    check  = c: let dups = c.conns |> map (e: e.raw) |> net.duplicates; in
      failIf (dups != []) "duplicate endpoint(s) on core: ${lib.concatStringsSep ", " dups}";
  })
  (mkAssert "core-invalid-root" "error" "resolve" {
    select = data: data |> cores |> rule.where (c: c.root != null);
    check  = c: require (lib.elem c.root.raw (map (e: e.raw) c.conns))
      "splice root '${c.root.raw}' is not in this core's endpoint list";
  })
  (mkAssert "core-name-collision" "error" "resolve" {
    select = cores;
    check  = c: failIf (c.name != null && c.id != "${c.cable}.${c.name}")
      "core name '${c.name}' is used more than once in cable '${c.cable}'";
  })

  ############ Validate ############
  (mkAssert "core-dangling" "warning" "validate" {
    select = cores;
    check  = c: failIf (count c < 2)
      "dangling core: ${toString (count c)} endpoint(s) (needs at least 2)";
  })
  (mkAssert "core-splice" "warning" "validate" {
    select = cores;
    check  = c: failIf (count c > 2 && c.root == null)
      "core joins ${toString (count c)} pins (a splice) but no root is declared";
  })
]; }
