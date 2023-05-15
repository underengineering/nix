{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.zsh;
in {
  options.jd.zsh = {
    enable = mkOption {
      description = "Enable zsh";
      type = types.bool;
      default = false;
    };
    initExtra = mkOption {
      description = "Extra commands that should be added to .zshrc.";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    programs.zsh = {
      enable = true;
      initExtra = cfg.initExtra;
    };
  };
}
