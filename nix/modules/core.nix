{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    resolved  = mkOption { type = types.attrs; default = {}; };
    asserts   = mkOption { type = types.listOf types.raw; default = []; };
    results   = mkOption { type = types.listOf types.raw; readOnly = true; };
    stats     = mkOption { type = types.attrs; readOnly = true; }; 
    output    = mkOption { type = types.attrs; readOnly = true; };
  };
  
  config = let
    # TODO: clarify
    judged = lib.concatMap (a: map (i: {
        inherit a i;
        msg = a.judge i.value;
      }) (a.select config.resolved)
    ) config.asserts;
    failed = lib.filter (x: x.msg != null) judged;
  in {
    results = map (x: {
      inherit (x.a) id severity;
      subject = x.i.subject;
      msg = x.msg;
    }) failed;
    stats   = { checked = lib.length judged; failed = lib.length failed; };
    output  = { inherit (config) resolved results stats; };
  };
}
