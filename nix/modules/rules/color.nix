{
  lib,
  rule,
  ...
}: let
  colors = resolved: resolved 
    |> rule.all "cables"
    |> rule.into "cores"
    |> rule.each 
    |> (rule.into "color");

  tokens = resolved: (colors resolved)
    |> rule.into "tokens"
    |> rule.each;
in {
  config.asserts = [
    (rule.mkAssert "color-invalid" "error" {
      select = tokens;
      judge  = t: if t.ty == "ERR" then "unknown color '${t.value}'" else null;
    })
  ];
}
