{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.lazygit;
in {
  options.modules.applications.lazygit = {
    enable = mkOption {
      description = "Enable lazygit";
      type = types.bool;
      default = true;
    };
    extraConfig = mkOption {
      description = "lazygit configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [pkgs.lazygit];
    xdg.configFile."lazygit/config.yml".text = cfg.extraConfig;
  };
}
