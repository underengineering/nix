{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.zsh;
in {
  options.modules.applications.zsh = {
    enable = mkOption {
      description = "Enable zsh";
      type = types.bool;
      default = true;
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
