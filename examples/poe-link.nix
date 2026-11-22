{ lib, ... }: let
  t = import ./templates.nix { inherit lib; };
in {
  connectors.switch.swPort1 = t.rj45 { 
    pins = t.poe.pins;
  };

  connectors.board.poeHdr   = {
    pinCount = 6;
    pins = t.poe.pins ++ [
      { name = "GND"; }
      { nc = true; }
    ]; 
  };

  cables.link = t.cat8 { 
    from = "swPort1"; 
    to = "poeHdr"; 
    pins = t.poe.pins;
  };

  # A splice box: cores that join more than two pins.
  connectors.engine.spliceBox = { 
    pinCount = 6; 
    pins = [ "A" "B" "C" "D" "E" "F" ] |> map (n: { name = n; });
  };

  cables.bus.cores = [
    { name = "lvA"; conns = [ "spliceBox#A" "spliceBox#B" "spliceBox#C" ]; }                       # no root: warning
    { name = "lvB"; conns = [ "spliceBox#D" "spliceBox#E" "spliceBox#F" ]; root = "spliceBox#D"; } # root declared
  ];

  # Deliberately broken extras.
  #connectors.engine.poeHdr = { 
  #  pinCount = 2;
  #};      # same connector name in another group

  #cables.extra.cores = 
  #  { conns = [ "swPort1#TX+" "poeHdr#NOPE" ]; color = "RDB"; }
  #  { conns = [ "swPort1#TX-" ]; }
  #  { name = "ground"; conns = [ "poeHdr#GND" "poeHdr#GND" ]; }
  #  { name = "ground"; conns = [ "spliceBox#A" "spliceBox#B" ]; root = "spliceBox#Z"; }
  #];

  #cables.empty = {};

  ignored = [ "core-dangling" ];
}
