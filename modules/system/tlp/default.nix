
{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.tlp;
in
{
  options.jd.tlp = {
    enable = mkOption {
      description = "Enable TLP service";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    services.tlp.enable = true;
  };
}
