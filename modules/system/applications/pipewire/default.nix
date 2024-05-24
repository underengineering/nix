{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.pipewire;
in {
  options.modules.applications.pipewire = {
    enable = mkOption {
      description = "Enable pipewire";
      type = types.bool;
      default = true;
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
