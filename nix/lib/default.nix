{
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.assertions = mkOption {
    type = types.listOf types.unspecified;
    default = []; internal = true;
  };

  options.warnings = mkOption {
    type = types.listOf types.str;
    default = []; internal = true;
  };

  options.output = mkOption {
    type = types.attrs;
    readOnly = true;
  };
}
