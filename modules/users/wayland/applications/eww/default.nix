{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.eww;
in {
  options.jd.eww = {
    enable = mkOption {
      description = "Enable eww";
      type = types.bool;
      default = false;
    };
    config = mkOption {
      description = "Eww configuration path";
      type = types.path;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [
      inputs.eww.packages.${pkgs.hostPlatform.system}.eww-wayland
    ];
  };
}
