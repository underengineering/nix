{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.greetd;
in {
  options.modules.applications.bluetooth = {
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
