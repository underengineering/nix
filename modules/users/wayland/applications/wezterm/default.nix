{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.wezterm;
in {
  options.modules.wezterm = {
    enable = mkOption {
      description = "Enable wezterm";
      type = types.bool;
      default = false;
    };
    config = mkOption {
      description = "Wezterm configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    programs.wezterm = {
      enable = true;
      extraConfig = cfg.config;
    };
  };
}
