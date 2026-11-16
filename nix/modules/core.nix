{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    resolved  = mkOption { type = types.attrs; default = {}; };
    rules     = mkOption { type = types.listOf types.raw; default = []; };
    output    = mkOption { type = types.attrs; readOnly = true; };
  };
  
  config = {
  };
}
