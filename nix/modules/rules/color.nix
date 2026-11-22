{
  lib,
  rule,
  ...
}: let
  inherit (rule) mkAssert failIf;

  colors = data: data |> rule.all "cores" |> rule.into "color";
  tokens = data: data |> colors |> rule.into "tokens" |> rule.each;
in { config.asserts = [
  (mkAssert "color-invalid" "error" "resolve" {
    select = tokens;
    check = t: failIf (t.ty == "ERR") "unknown color '${t.val}'";
  })
  (mkAssert "render-fallback" "warning" "output" {
    select = rule.all "cores";
    check = c: failIf c.colorFallback
      "color cannot be rendered; drawn with placeholder color"; 
  })
]; }
