{lib}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (builtins) hasAttr;
in {
  host-config = presets: keyfiles: hosts:
    mapAttrs (
      _name: value:
        presets
        // {
          inherit (value) hostname;
        }
        // (
          if keyfiles == null
          then {}
          else {
            identityFile = keyfiles;
          }
        )
        // (
          if hasAttr "overrides" value
          then value.overrides
          else {}
        )
    )
    hosts;
}
