{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.applications.hyprland;
in {
  options.modules.wayland.applications.hyprland = {
    enable = mkOption {
      description = "Enable hyprland";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    programs.hyprland.enable = true;
  };
}
