{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  wireSubmodule = types.submodule ({
    name, ...
  }: {
    options = {
      wireGauge = mkOption { type = types.str; }; # This is temporary
      
      pinNames = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Pins carried by this wire";
      };
      pinColors = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Colors by pin in order";
      };
    };

    config = {};
  });
in {

}
