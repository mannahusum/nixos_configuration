{ pkgs, services, hardware, ... }:
{
  programs.system-config-printer.enable = true;
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        (callPackage ./pkgs/cups-kyocera5012/default.nix {})
        cups-kyocera
        cups-kyodialog3
        gutenprint
        hplipWithPlugin
      ];
      startWhenNeeded = true;
    };
    system-config-printer.enable = true;
  };
  hardware = {
    printers = {
      ensureDefaultPrinter = "kyocera5012cdw";
      # ensurePrinters = [
      #   {
      #     description = "Mein chicker Laserdrucker";
      #     deviceUri = "dnssd://Kyocera%20ECOSYS%20P5021cdw._ipp._tcp.local/?uuid=4509a320-0061-004d-0036-0025074fb3d9";
      #     location = "79Dachboden5";
      #     model = "";
      #     name = "kyocera5012cdw";
      #     ppdOptions = {};
      #   }
      # ];
    };
    sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };
}
