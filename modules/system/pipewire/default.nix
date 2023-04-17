{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.pipewire;
in
{
  options.jd.pipewire = {
    enable = mkOption {
      description = "Enable pipewire";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}
