{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.tlp;
in {
  options.modules.applications.tlp = {
    enable = mkOption {
      description = "Enable TLP service";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    services.tlp.enable = true;
  };
}
