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
  };
  config = mkIf (cfg.enable) {
    wayland.windowManager.hyprland.enable = true;
  };
}
