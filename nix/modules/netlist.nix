{
  lib,
  net,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.netlist = mkOption { type = types.attrs; readOnly = true; };

  config.netlist = let
    res = config.resolved;
    endpoints = net.endpoints res;
  in {
    inherit endpoints;
    coreEnds   = net.coreEnds   res endpoints;
    pins       = net.pins       res endpoints;
    cableCores = net.cableCores res;
  };

  config.phases.resolve  = config.resolved // config.netlist;
  config.phases.validate = config.resolved // config.netlist;
}
