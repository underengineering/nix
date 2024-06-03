{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.hyprland;
in {
  options.modules.wayland.hyprland = {
    enable = mkOption {
      description = "Enable hyprland";
      type = types.bool;
      default = true;
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
