{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.kernel;
  wlanVendors = [
    "admtek"
    "ath"
    "atmel"
    "broadcom"
    "cisco"
    "intel"
    "intersil"
    "marvell"
    "mediatek"
    "microchip"
    "purelifi"
    "quantenna"
    "ralink"
    "realtek"
    "rsi"
    "silabs"
    "st"
    "ti"
    "zydas"
  ];
in {
  options.jd.kernel = {
    patches = mkOption {
      description = "Kernel patches";
      type = with types; listOf attrs;
      default = [];
    };
  };
  config = {
    boot.kernelPatches = cfg.patches;
  };
}
