{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.wezterm;
in {
  options.modules.wayland.wezterm = {
    enable = mkOption {
      description = "Enable wezterm";
      type = types.bool;
      default = true;
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
