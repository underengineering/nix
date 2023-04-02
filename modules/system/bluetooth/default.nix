{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.greetd;
in {
  options.jd.bluetooth = {
    enable = mkOption {
      description = "Enable Bluetooth support";
      type = types.bool;
      default = false;
    };
  };
  config = {
    hardware.bluetooth.enable = true;
  };
}
