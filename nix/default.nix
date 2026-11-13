{
  lib,
  ...
}: let
  inherit (lib) types;
in {
  evalHarness = modules: let
    eval = lib.evalModules {
      specialArgs = {};
      modules = [] ++ modules;
    };
    failed = lib.filter (a: !a.assertion) eval.config.assertions;
  in if failed != [] then
    throw ("Harness errors:\n" + lib.concatMapStringsSep "\n" (a: "- ${a.message}") failed)
  else lib.showWarnings eval.config.warnings eval.config.output;
}
