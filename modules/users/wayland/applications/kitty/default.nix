{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.kitty;
in
{
  options.jd.kitty = {
    enable = mkOption {
      description = "Enable kitty";
      type = types.bool;
      default = false;
    };
    config = mkOption {
      description = "Kitty configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    programs.kitty = {
      enable = true;
      extraConfig = cfg.config;
    };
  };
}
