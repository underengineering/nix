{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.swaylock;
in {
  options.modules.wayland.swaylock = {
    enable = mkOption {
      description = "Enable swaylock-effects";
      type = types.bool;
      default = true;
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
