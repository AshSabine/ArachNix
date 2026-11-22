{
  lib
}: let
  inherit (lib) mkOption types;
  
  ########### Tree Denesting #############
  # TODO: Temporary function to use until I figure out a good solution for
  # detecting leaf nodes.
  isLeaf = x: lib.isAttrs x && (x ? pinCount);

  /**
    Option type for a tree. `isLeaf` tells a leaf from a group in the
    RAW declaration. Explicit descriptions keep error messages read-
    -able, since a recursive type cannot describe itself.
  */
  mkTree = { leaf, isLeaf, leafName }: let

    leafT = (types.addCheck leaf isLeaf) // { description = leafName; };
    t = (types.attrsOf (types.either leafT t)) // {
      description = "${leafName}, or group of ${leafName}s";
    };
  in t;
  
  # TODO: This was imported from the old `module/items/conn.nix`. Verify func-
  # -tionality prior to release. Functionality to detect collisions here has
  # been deprecated and moved into rules.
  denest = path: attrs: if attrs ? pinCount then [{
    name = lib.last path;
    groups = lib.init path;
    value = attrs;
  }] else lib.concatMap (name:
    denest (path ++ [name]) attrs.${name}
  ) (builtins.attrNames attrs);
  
  # TODO: name -> leaf. First declaration wins, duplicates reported by assert.
  index = tree: let
    lam = map (l: lib.nameValuePair l.name l);
  in (denest [] tree) 
    |> lam |> lib.listToAttrs;
in {
  inherit mkTree isLeaf denest index;

  request = types.submodule { options = {
    name  = mkOption { type = types.nullOr types.str; default = null; };
    num   = mkOption { type = types.nullOr types.int; default = null; };
    nc    = mkOption { type = types.bool; default = false; };
  }; };
}
