{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.tlp;
in {
  options.modules.tlp = {
    enable = mkOption {
      description = "Enable TLP service";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    services.tlp.enable = true;
    powerManagement.cpuFreqGovernor = "conservative";
  };
}
