{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.starship;
in
{
  options.jd.starship = {
    enable = mkOption {
      description = "Enable starship";
      type = types.bool;
      default = false;
    };
    extraConfig = mkOption {
      description = "Starship configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    programs.starship = {
      enable = true;
      enableFishIntegration = false;
      enableIonIntegration = false;
      enableNushellIntegration = false;
      settings = cfg.extraConfig;
    };
  };
}
