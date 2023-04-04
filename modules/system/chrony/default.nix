{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.chrony;
in
{
  options.jd.chrony = {
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
