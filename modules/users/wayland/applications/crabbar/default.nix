{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.crabbar;
in {
  options.modules.wayland.crabbar = {
    enable = mkOption {
      description = "Enable crabbar";
      type = types.bool;
      default = true;
    };
    config = mkOption {
      description = "Crabbar configuration";
      type = types.attrs;
      default = {};
    };
    cssConfig = mkOption {
      description = "CSS configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [pkgs.crabbar];
    xdg.configFile = {
      "crabbar/config.json" = {
        text = builtins.toJSON cfg.config;
      };
      "crabbar/style.css" = {
        text = cfg.cssConfig;
      };
    };
  };
}
