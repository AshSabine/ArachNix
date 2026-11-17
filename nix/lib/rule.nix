{
  lib
}: let
  # TODO: Find more descriptive names than `select`, `subject`, `judge`.
  # TODO: Break out the { subject = ...; value = ...; } pattern into a lambda
  # to ease readability.
in rec {
  /**
    Selectors turn a resolved layer into items: `{ subject; value; }`.
    Each selector extends the subject path, so asserts never build 
    paths by hand.
  */

  # all "cables" :: resolved -> [ item ]
  # one item per object of type
  selectAll = ty: resolved: let
    allTy = resolved.${ty} or {};
    selector = id: v: { subject = "${ty}.${id}"; value = v; };
  in allTy |> (lib.mapAttrsToList selector);
  
  # into "color" :: [ item ] -> [ item ]
  # descend into a field (skip if absent)
  into = field: items: let
    hasField = item: lib.optional (item.value ? ${field}) {
      subject = "${i.subject}.${field}";
      value = i.value.${field};
    };
  in items |> (lib.concatMap hasField);

  # each :: [ item ] -> [ item ]
  # fan a list (symb[0]) or an attrset (.H) out into items
  each = items: let
    toResult  = k: v: {
      subject = "{i.subject}.{k}";
      value = v;
    };

    toResults = n: v: { 
      subject = "${i.subject}[${toString n}]";
      value = v;
    };
  in items |> lib.concatMap (item: if lib.isList item.value
    then lib.imap0 toResults item.value; 
    else lib.mapAttrsToList toResults item.value;
  );

  /**
    An assert selects items, then judges each one.

    # Type
    ```
    mkAssert :: String -> String -> { select :: attrSet -> [item]; judge :: a -> null | String; } -> Assert
    ```
    `judge` returns `null` when the item passes, or a message describing the problem.
  */
  mkAssert  = id: severity: { select, judge }: { inherit id severity select judge; };
}
