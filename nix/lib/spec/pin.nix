{
  lib
}: let
  inherit (lib) mkOption types;

  parse = raw: let
    m = builtins.match "([^#]+)#(.+)" raw;
    nullOrIdx = i: if m == null then null else builtins.elemAt m i;
  in {
    inherit raw;
    conn = nullOrIdx 0;
    pin  = nullOrIdx 1;
  };
in {
  inherit parse;
  type = let
    end = types.submodule { options = {
      raw  = mkOption { type = types.str; };
      conn = mkOption { type = types.nullOr types.str; };
      pin  = mkOption { type = types.nullOr types.str; };
    }; };
  in types.coercedTo types.str parse end;
}
