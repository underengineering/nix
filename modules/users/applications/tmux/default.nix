{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.tmux;
in {
  options.jd.tmux = {
    enable = mkOption {
      description = "Enable tmux";
      type = types.bool;
      default = false;
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
