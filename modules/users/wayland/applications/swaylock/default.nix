{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.swaylock;
in {
  options.jd.swaylock = {
    enable = mkOption {
      description = "Enable swaylock-effects";
      type = types.bool;
      default = false;
    };
    config = mkOption {
      description = "Swaylock config";
      type = with types; attrsOf (either bool (either float (either int str)));
      default = {};
    };
  };
  config = mkIf (cfg.enable) {
    # TODO: Configure pam.d
    home.packages = with pkgs; [swaylock-effects];
    programs.swaylock.settings = cfg.config;
  };
}
