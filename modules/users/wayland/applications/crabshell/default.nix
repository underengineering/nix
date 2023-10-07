{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.crabshell;
in {
  options.jd.crabshell = {
    enable = mkOption {
      description = "Enable crabshell";
      type = types.bool;
      default = false;
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
