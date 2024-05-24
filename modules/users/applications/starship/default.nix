{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.starship;
in {
  options.modules.applications.starship = {
    enable = mkOption {
      description = "Enable starship";
      type = types.bool;
      default = true;
    };
    extraConfig = mkOption {
      description = "Starship configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [pkgs.starship];
    xdg.configFile."starship.toml".text = cfg.extraConfig;
  };
}
