{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.fprintd;
in {
  options.jd.fprintd = {
    enable = mkOption {
      description = "Enable fprintd";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    services.fprintd = {
      enable = true;
    };
  };
}
