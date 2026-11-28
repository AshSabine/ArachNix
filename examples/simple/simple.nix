{
  lib,
  std,
  ...
}: let
  inherit (std) mkPins pin2pin pinsFor;

  canPins = mkPins [ "CAN_H" "CAN_L" ];

  dt4 = { pins ? [] }: {
    pinCount = 4;
    connType = "female";
    bom.desc = "Deutsch DT 4-pin";
    inherit pins;
  };
in {
  ############# CONNECTORS ##############
  connectors.powertrain.ecu = dt4 {
    pins = canPins ++ [
      { name = "12V"; }
      { nc = true; }
    ];
  };
  
  connectors.cockpit.dash = {
    pinCount = 5;
    pins = canPins ++ [
      { name = "12V"; }
      { nc = true; }
    ];
  };
  
  connectors.chassis.sensor = dt4 {
    pinCount = 3;
    pins = mkPins [ "12V" "GND" "SIG" ];
  };
  
  ############### CABLES ################
  cables.canBus = {
    bom.desc = "Twisted CAN pair";
    cores = pin2pin "ecu" "dash" {
      pins = canPins;
      colors = [ "WH:GN" "GN" ];
    };
  };

  cables.power.cores = [
    # 2-pin core
    {
      name = "gnd";
      conns = [ "ecu#GND" "sensor#GND" ];
      color = "BK";
    }
    # Dangling (1-pin) core
    {
      name = "spare";
      conns = [ "sensor#SIG" ];
      color = "YE";
    }
    # 3-pin splice with explicit root
    {
      name = "v12";
      conns = [ "ecu#12V" "dash#12V" "sensor#12V" ];
      root = "ecu#12V";
      color = "RD";
    }
    # 3-pin splice WITHOUT root
    {
      name = "jumper";
      conns = pinsFor "jBox" [ "A" "B" "C" ];
    }
  ];
  
  ############ DIAGNOSTICS ##############
  ignored = [ "core-dangling" ];
}
