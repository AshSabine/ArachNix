{
  config,
  lib,
  ...
}: let
  inherit (builtins) concatLists filter isList split;
  inherit (lib) mkOption types;

  baseColors = [
    "BK" "WH" "GY" "PK" "RD" "OG" "YE" "OL" "GN" "TQ" "LB" "BU" "VT" "BN" "BG" "IV" "SL" "CU" "SN" "SR" "GD"
  ];

  colorType = types.submodule {
    options = {
      codes = mkOption { type = types.listOf types.str; };
      isHex = mkOption { type = types.bool; };
    };
  };

  chunkIEC = str: str 
    |> (split "([A-Z]{2})")
    |> (filter isList)
    |> concatLists;

  parseColor = str: let
    isHex = lib.hasPrefix "#" str;
    codes = if isHex then lib.splitString ":" else chunkIEC str;
    invalid = filter (c: !(builtins.elem baseColors c)) codes;
  in if !isHex && invalid != [] then
    throw "ERROR: Unknown IEC color code ${builtins.toJSON invalid}"
  else { inherit codes isHex; }
in {
  options.types.colorType = types.coercedTo types.str parseColor colorType;
}
