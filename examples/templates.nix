# A user's template file. Templates are plain lambdas that return declarations.
{ lib }: rec {
  # A pin group is just a list of pin requests.
  poe.requests = map (n: { name = n; }) [ "TX+" "TX-" "RX+" "RX-" ];

  rj45 = { requests ? [] }: {
    pinCount = 8;
    connType = "female";
    bom.desc = "RJ45 jack";
    inherit requests;
  };

  # Wires two connectors pin-for-pin BY NAME: one core per pin, touching both.
  cat8 = { from, to, requests }: {
    bom.desc = "Cat8 cable";
    cores = requests |> lib.imap0 (i: p: {
      conns = [ "${from}#${p.name}" "${to}#${p.name}" ];
      color = lib.elemAt [ "WH:BU" "BU" "WH:OG" "OG" ] (lib.mod i 4);
    });
  };
}
