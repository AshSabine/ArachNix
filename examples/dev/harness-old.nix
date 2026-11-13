{ lib, ... }:
let
  # 1. Define standard connector/wire templates
  templates = {
    canBus = fromBoard: toBoard: [
      { from = "${fromBoard}#CAN_H"; to = "${toBoard}#CAN_H"; wire = "22AWG_Twisted"; }
      { from = "${fromBoard}#CAN_L"; to = "${toBoard}#CAN_L"; wire = "22AWG_Twisted"; }
    ];
    threePhase = motor: inverter: [
      { from = "${motor}#U"; to = "${inverter}#U"; wire = "0AWG"; }
      { from = "${motor}#V"; to = "${inverter}#V"; wire = "0AWG"; }
      { from = "${motor}#W"; to = "${inverter}#W"; wire = "0AWG"; }
    ];
  };

  # 2. B2B Groups "paint" the topology
  # We just declare the relationships, Nix generates the P2P arrays
  generatedP2P = lib.flatten [
    (templates.threePhase "M1" "INV")
    (templates.threePhase "M2" "INV")
    (templates.canBus "BMS" "INV")
  ];

  # 3. Granular overrides for the 10% that don't fit the template
  manualP2P = [
    { from = "M1#TEMP"; to = "INV#SENSE_1"; wire = "24AWG"; connector = "Molex_MicroFit"; }
  ];

  # Final P2P is the combination of painted and manual
  allP2P = generatedP2P ++ manualP2P;

  # 4. N2N routing
  # You could even group wires into "bundles" here to route them together
  bundles = {
    HV_Tract = { wires = [ "M1#U" "M1#V" "M1#W" ]; path = [ "node_1" "node_2" ]; };
  };
in {
  p2p = allP2P;
  inherit bundles;
}