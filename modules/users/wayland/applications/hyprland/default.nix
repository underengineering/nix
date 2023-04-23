{ inputs }:
{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.hyprland;

  # TODO: Move to overlays
  hyprland-lto = pkgs.hyprland.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = toString (old.NIX_CFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
    NIX_CXXFLAGS_COMPILE = toString (old.NIX_CXXFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
    NIX_LDFLAGS = toString (old.NIX_LDFLAGS or "") + " -flto=15";
  });
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
      package = hyprland-lto;
      extraConfig = cfg.extraConfig;
    };
  };
}
