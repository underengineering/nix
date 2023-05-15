{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.hyprland;
in {
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
      package = pkgs.hyprland-lto;
      extraConfig = cfg.extraConfig;
    };
  };
}
