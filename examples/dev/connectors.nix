{
  templates,
  ...
}: let
  inherit (templates.connectors) jst-xhp-2;  
in {
  connectors.inv = {
    canA = jst-xhp-2;
    canB = jst-xhp-2;
  };

  connectors.bms = {
    canA = jst-xhp-2;
    canB = jst-xhp-2;
  };
}
