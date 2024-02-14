{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {
    enable = mkOption {
      description = "Enable hyprland";
      type = types.bool;
      default = false;
    };
    extraConfig = mkOption {
      description = "Hyprland config";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = cfg.extraConfig;
    };
  };
}
