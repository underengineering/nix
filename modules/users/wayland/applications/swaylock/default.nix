{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.swaylock;
in {
  options.modules.swaylock = {
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
    home.packages = with pkgs; [swaylock-effects];
    programs.swaylock.settings = cfg.config;
  };
}
