{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.chrony;
in {
  options.modules.applications.chrony = {
    enable = mkOption {
      description = "Enable chrony. Disables timesyncd.";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    services.timesyncd.enable = false;
    services.chrony.enable = true;
  };
}
