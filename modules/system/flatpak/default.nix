{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.flatpak;
in {
  options.modules.flatpak = {
    enable = mkOption {
      description = "Enable flatpak";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    services.flatpak.enable = true;
  };
}
