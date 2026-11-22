{
  rule,
  ...
}: { config.asserts = [
  (rule.mkAssert "cable-empty" "warning" "validate" {
    select = rule.all "cableCores";
    check  = c: rule.failIf (c.count == 0) "cable has no cores declared";
  })
]; }
