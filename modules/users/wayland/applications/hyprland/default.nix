{ pkgs, config, lib, hyprland, ... }:
with lib;
let
  cfg = config.jd.hyprland;
in
{
  options.jd.hyprland = {
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
