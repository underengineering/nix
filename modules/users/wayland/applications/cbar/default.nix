{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.cbar;
in {
  options.jd.cbar = {
    enable = mkOption {
      description = "Enable cbar";
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
      inputs.cbar.defaultPackage.${pkgs.hostPlatform.system}
    ];
  };
}
