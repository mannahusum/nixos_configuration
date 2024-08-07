{lib}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (builtins) hasAttr toFile substring readFile filter;

  identityFiles = publickeys: map (toFile ".pub") (
    filter (key: (substring 0 3 key) == "ssh") (
      lib.strings.splitString "\n" (readFile ''${publickeys}'')
    ));

in {
  host-config = presets:  keyfiles: hosts:
  mapAttrs (
    name:
    value:
    presets
    // {
       inherit (value) hostname;
    }
    // (if keyfiles == null then {} else {
        identityFile = keyfiles;
    })
    // (if hasAttr "overrides" value then value.overrides else {})
  ) hosts;
}
