# A user's template file. Templates are plain lambdas that return declarations.
{
  lib,
  std
}: let
  inherit (std) mkPins pin2pin;
in rec {
  # A pin group is just a list of pin requests.
  poe.pins = mkPins [ "TX+" "TX-" "RX+" "RX-" ];

  rj45 = { pins ? [] }: {
    pinCount = 8;
    connType = "female";
    bom.desc = "RJ45 jack";
    inherit pins;
  };

  # Wires two connectors pin-for-pin BY NAME: one core per pin, touching both.
  cat8 = a: b: pins: {
    bom.desc = "CAT8 Cable";
    cores = pin2pin a b {
      inherit pins;
      colors = [ "WH:BU" "BU" "WH:OG" "OG" ];
    };
  };
}
