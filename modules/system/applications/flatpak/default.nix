{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.flatpak;
in {
  options.modules.applications.flatpak = {
    enable = mkOption {
      description = "Enable flatpak";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    services.flatpak.enable = true;
  };
}
