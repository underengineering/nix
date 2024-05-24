{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.tmux;
in {
  options.modules.applications.tmux = {
    enable = mkOption {
      description = "Enable tmux";
      type = types.bool;
      default = true;
    };
    configPath = mkOption {
      description = "Path to the config";
      type = types.str;
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [pkgs.tmux];
    xdg.configFile.tmux.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/${cfg.configPath}";
  };
}
