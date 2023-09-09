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
    # config = mkOption {
    #   description = "Cbar configuration path";
    #   type = types.path;
    #   default = "";
    # };
  };
  config = mkIf (cfg.enable) {
    home.packages = [
      inputs.crabshell.defaultPackage.${pkgs.hostPlatform.system}
    ];
  };
}
