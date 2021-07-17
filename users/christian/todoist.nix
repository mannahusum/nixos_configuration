{ lib, pkgs, home, ... }:

let
    writeShellScriptBinAndSymlink = import ./writeShellScriptBinAndSymlink.nix {
      inherit pkgs;
    };
in {
  home.packages = with pkgs; [
    todoist
    (
      writeShellScriptBinAndSymlink "todone" ''
        ${pkgs.todoist.out}/bin/todoist close "$@"
      ''
    )(
      writeShellScriptBinAndSymlink "todo" ''
        declare ort="$1"; shift
        declare search="( today | overdue)"

        if [ -n "$ort" ]; then
          search+=" & @$ort"
        fi

        ${pkgs.todoist.out}/bin/todoist list -f "$search"
      ''
    )
  ];
}
