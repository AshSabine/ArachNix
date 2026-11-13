{ ... }: {
  myWire = {
    name = "Example Wire";
    pins = [ "A" "B" "C" ];

    properties = {
       diam = withUnits 2.0 "mm";
       bend = withUnits 0.63 "in";
    };

    visual = {
      colors = [ "#FFFF00" "#00FFFF" "#FF00FF" ];
      stroke = 2.0;
      braid = true;
    };
  };
}
