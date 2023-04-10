{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.wezterm;
in
{
  options.jd.wezterm = {
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
