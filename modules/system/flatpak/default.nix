{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.flatpak;
in
{
  options.jd.flatpak = {
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
