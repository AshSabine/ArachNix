{
  lib
}: let
  arx = import ./lib { inherit lib; };
in {
  inherit arx;

  evalHarness = extra: let
    eval = lib.evalModules {
      modules = (import ./module) ++ extra;
      specialArgs = {
        inherit (arx) data rule spec;
      };
    };

    cfg = eval.config;
  in {
    inherit (cfg) results stats output;
    ok = !(lib.any (r: r.severity == "error") cfg.results);
  }
}
