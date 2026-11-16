{
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  lib2 = lib.extend (final: prev: {
    arachnix = import ./lib { lib = final; };
  });
in {
  evalHarness = modules: let
    eval = lib2.evalModules {
      specialArgs.lib = lib2;
      modules = [] ++ modules;
    };
    failed = lib.filter (a: !a.assertion) eval.config.assertions;
  in if failed != [] then
    throw ("Harness errors:\n" + lib.concatMapStringsSep "\n" (a: "- ${a.message}") failed)
  else lib.showWarnings eval.config.warnings eval.config.output;
}
