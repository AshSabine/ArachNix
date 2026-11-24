{
  lib
}: let
  arx = import ./lib { inherit lib; };
in {
  inherit arx;

  evalHarness = extra: let
    eval = lib.evalModules {
      modules = [ ./modules ] ++ extra;
      specialArgs = {
        inherit (arx) std net data spec rule;
      };
    };

    cfg = eval.config;
    results = cfg.results
      |> lib.attrValues
      |> lib.concatLists;
  in {
    inherit results;
    inherit (cfg) stats resolved netlist output;
    ok = !(lib.any (r: r.severity == "error" && !r.ignored) results);
  };
}
