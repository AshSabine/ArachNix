{
  lib,
  ...
}: let
  # TODO: find some way to do absolute filepaths. Alternatively this could be
  # bypassed with some automatic loading logic exporting everything in json/
  inherit (builtins) fromJSON readFile;
  readJSON = name: fromJSON (readFile ../../json/${name}.json);
in {
  inherit readJSON;
  iec60757 = readJSON "iec-60757";
}
