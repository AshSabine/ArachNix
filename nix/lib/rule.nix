{
  lib,
  ...
}: let
  
in {
  mkRule = id: severity: check: { inherit id severity check; };

  mapResolved = ty: check: resolved: let
    allTy = resolved.${ty} or {};
  in allTy |> (lib.mapAttrsToList check) |> lib.concatLists;
}
