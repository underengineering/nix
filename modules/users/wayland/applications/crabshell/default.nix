{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.crabshell;
in {
  options.modules.wayland.crabshell = {
    enable = mkOption {
      description = "Enable crabshell";
      type = types.bool;
      default = true;
    };
    configPath = mkOption {
      description = "Path to the config";
      type = types.str;
    };
  };
  config = mkIf (cfg.enable) {
    xdg.configFile.crabshell.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/${cfg.configPath}";
    home.packages = [
      inputs.crabshell.defaultPackage.${pkgs.hostPlatform.system}
    ];
  };
}
