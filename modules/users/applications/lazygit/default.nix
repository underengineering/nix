{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.lazygit;
in {
  options.jd.lazygit = {
    enable = mkOption {
      description = "Enable lazygit";
      type = types.bool;
      default = false;
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
