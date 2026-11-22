{
  lib
}: let
  mkItem = path: value: { inherit path value; };
in {
  /**
    An assert selects items, then checks each one.

    # Type
    ```
    mkAssert :: String -> String -> String -> { select :: attrSet -> [item]; check :: a -> null | String; } -> Assert
    ```
    `check` returns `null` when the item passes, or a message describing the problem.
  */
  mkAssert  = id: severity: stage: { select, check }: { 
    inherit id severity stage select check;
  };

  # Short macro to make selectors easier.
  # Check helpers
  failIf  = cond: text: if cond then text else null;
  require = cond: text: if cond then null else text;

  /**
    Selectors turn a resolved layer into items: `{ path; value; }`.
    Each selector extends the path, so asserts never build 
    paths by hand.
  */

  # all "cables" :: resolved -> [ item ]
  # one item per object of type
  all = ty: resolved: let
    allTy = resolved.${ty} or {};
    selector = id: v: mkItem "${ty}.${id}" v;
  in allTy |> (lib.mapAttrsToList selector);
  
  # into "color" :: [ item ] -> [ item ]
  # descend into a field (skip if absent)
  into = field: items: let
    hasField = item: lib.optional
      (item.value ? ${field} && item.value.${field} != null) 
      (mkItem "${item.path}.${field}" item.value.${field});
  in items |> (lib.concatMap hasField);

  # each :: [ item ] -> [ item ]
  # fan a list (symb[0]) or an attrset (.H) out into items
  each = items: items |> lib.concatMap (item:
    if builtins.isList item.value
    then item.value |> lib.imap0 (k: v: 
      mkItem "${item.path}[${toString k}]" v)
    else item.value |> lib.mapAttrsToList (n: v: 
      mkItem "${item.path}.${n}" v)
  );

  # Keep items whose value satisfies a predicate
  where = pred: builtins.filter (item: pred item.value);
}
