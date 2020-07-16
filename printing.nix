{ pkgs, services, ... }:
{
  programs.system-config-printer.enable = true;
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-kyocera
        cups-kyodialog3
        gutenprint
        hplip
      ];
      startWhenNeeded = true;
    };
    system-config-printer.enable = true;
  };
}
