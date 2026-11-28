{
  lib,
  std,
  ...
}: let
  inherit (std) mkPins pinsFor;
  t = import ./templates.nix { inherit lib std; };
in {
  connectors.switch.swPort1 = t.rj45 { pins = t.poe.pins; };

  connectors.board.poeHdr = {
    pinCount = 6;
    pins = t.poe.pins ++ [
      { name = "GND"; }
      { nc = true; }
    ]; 
  };

  cables.link = t.cat8 "swPort1" "poeHdr" t.poe.pins;

  # A splice box: cores that join more than two pins.
  connectors.engine.spliceBox = { 
    pinCount = 6; 
    pins = mkPins [ "A" "B" "C" "D" "E" "F" ];
  };

  cables.bus.cores = [
    { name = "lvA"; conns = pinsFor "spliceBox" [ "A" "B" "C" ]; }                       # no root: warning
    { name = "lvB"; conns = pinsFor "spliceBox" [ "D" "E" "F" ]; root = "spliceBox#D"; } # root declared
  ];

  # Deliberately broken extras.
  connectors.engine.poeHdr = { 
    pinCount = 2;
  };      # same connector name in another group

  cables.extra.cores = [
    { conns = [ "swPort1#TX+" "poeHdr#NOPE" ]; color = "RDB"; }
    { conns = [ "swPort1#TX-" ]; }
    { name = "ground"; conns = pinsFor "poeHdr" [ "GND" "GND" ]; }
    { name = "ground"; conns = pinsFor "spliceBox" [ "A" "B" ]; root = "spliceBox#Z"; }
  ];

  #cables.empty = {};

  ignored = [ "core-dangling" ];
}
