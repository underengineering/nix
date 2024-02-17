{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.greetd;
in {
  options.modules.bluetooth = {
    enable = mkOption {
      description = "Enable Bluetooth support";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    hardware.bluetooth.enable = true;
  };
}
