{
  lib,
}: let
  inherit (builtins) length;
in rec {
  ############## Shortcuts ##############
  # Simple shortcut for a N/C pin
  nc = { nc = true; };
  
  ############# Pin Helpers #############
  /** TODO: apply RFC 145
    Mixed list shorthand for describing a connector's pins.
    example: mkPins [ "GND" null { name = "VCC"; num = 1; } ]
      string  -> named pin
      null    -> N/C
      attrset -> passthru
  */
  mkPins = map (p:
    if builtins.isString p  then { name = p; }
    else if p == null       then nc
    else p
  );

  /** TODO: apply RFC 145
    Pad a connectors pins up to `pinCount` with N/C pins.
    example: myConn = { ... } |> fillNC
  */
  fillNC = conn: let
    pins = conn.pins or [];
    rem  = conn.pinCount - length pins;
  in conn // {
    pins = pins ++ lib.genList
      (_: { nc = true; })
      (lib.max 0 rem);
  };

  ############ Cable Helpers ############
  /** TODO: apply RFC 145
    Shorthand to expand a list of pins on a connector.
  */
  pinsFor = conn: map (pin: "${conn}#${pin}");


  /** TODO: apply RFC 145
    Shorthand for wiring two connectors pin-to-pin, optionally including color.
  */
  pin2pin = a: b: { pins, colors ? [] }: let
    toIdx = i: lib.mod i (length pins);
  in lib.imap0 (i: p: {
    conns = [ "${a}#${p.name}" "${b}#${p.name}" ];
  } // lib.optionalAttrs (colors != []) {
    color = lib.elemAt colors (toIdx i);
  }) pins;
}
