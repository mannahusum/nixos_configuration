{pkgs}:
name: text: pkgs.symlinkJoin {
  name = name;
  paths = [
    (pkgs.writeShellScriptBin name text)
  ];
}
