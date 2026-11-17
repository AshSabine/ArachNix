{
  lib,
  data,
}: let
  inherit (builtins) match split filter isList concatLists;
  inherit (lib) mkOption types concatMap toUpper splitString;
  
  ########### External Data #############
  iec = fromJSON (readFile ../../json/iec-60757.json);
  allColors = iec // extraColors;

  reHex = "#[0-9A-Fa-f]{6}";
  reIEC = "[A-Z]{2}";
  
  ############## Parsing ################
  mkColor = ty: val: hex: { inherit ty val hex; };
  
  chunk = pattern: str: str 
    |> (split pattern)
    |> (filter isList)
    |> concatLists;

  parse = raw: let
    expand = tok:
      if allColors ? ${tok} then [ tok ]
      else if match "(${reIEC})+" tok != null then chunk reIEC tok
      else [ tok ];

    classify = tok:
      if match reHex tok != null then mkColor "HEX" tok tok;
      else if registry ? {tok} then   mkColor "IEC" tok allColors.${tok}.hex;
      else                            mkColor "ERR" tok null;
  in {
    inherit raw;
    tokens = raw 
      |> toUpper
      |> splitString ":"
      |> concatMap expand
      |> map classify;
  }

  ############# Submodule ###############
  submodule = types.submodule { options = {
    raw     = mkOption { type = types.str; };
    tokens  = mkOption { type = types.listOf types.attrs; };
  }; };
in {
  inherit parse;
  type = types.coercedTo types.str parse submodule;
}
