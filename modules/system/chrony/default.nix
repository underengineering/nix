{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.chrony;
in {
  options.modules.chrony = {
    enable = mkOption {
      description = "Enable chrony. Disables timesyncd.";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    services.timesyncd.enable = false;
    services.chrony.enable = true;
  };
}
