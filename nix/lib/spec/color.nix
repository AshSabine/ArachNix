{
  lib,
  extraColors ? {},
}: let
  inherit (builtins) concatLists filter isList split readFile fromJSON;
  inherit (lib) mkOption splitString types;

  iec = fromJSON (readFile ../../json/iec-60757.json);
  allColors = iec // extraColors;

  reHex = "(#[0-9A-Fa-f]{6})";
  reIEC = "([A-Z]{2})";
in {
  ############## Parsing ################
  chunkBy = pattern: str: str 
    |> (split pattern)
    |> (filter isList)
    |> concatLists;

  toChunks = str:
    if match "${reHex}+" != null
    then chunkIEC str
    else [ str ];

  parseColor = raw: let
    chunks = toChunks (splitString ":" raw)
  in {}


  parseColor = str: let
    isHex = builtins.match reHex str;
    codes = toChunks str;
    invalid = filter (c: !(builtins.elem baseColors c)) codes;
  in if !isHex && invalid != [] then
    throw "ERROR: Unknown IEC color code ${builtins.toJSON invalid}"
  else { inherit codes isHex; }
  
  ############# Submodule ###############
  colorSubmodule = types.submodule {
    options = {
      codes = mkOption { type = types.listOf types.str; };
      isHex = mkOption { type = types.bool; };
    };
  };

  colorType = types.coercedTo types.str parseColor colorSubmodule;
}
