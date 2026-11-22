{
  lib,
}: let
  inherit (lib) mkOption types;
in {
  type = types.submodule { options = {
    mfr  = mkOption { type = types.nullOr types.str; default = null; };
    sku  = mkOption { type = types.nullOr types.str; default = null; };
    desc = mkOption { type = types.nullOr types.str; default = null; };
  }; };
}
