{ lib, pkgs, home, ... }:

{
  home.file.".taskrc" = with pkgs.taskwarrior; {
    text = ''
      data.location=~/.task
      include ${out}/share/doc/task/rc/solarized-light-256.theme

      calendar.holidays=sparse
      include ${out}/share/doc/task/rc/holidays.de-DE.rc
    '';
  };
  home.packages = with pkgs; [
    taskwarrior
    vit
  ];
}

