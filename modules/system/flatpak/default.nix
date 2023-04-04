{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.flatpak;
in
{
  options.jd.flatpak = {
    enable = mkOption {
      description = "Enable flatpak. Enables XDG portal";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    xdg.portal.enable = true;
    services.flatpak.enable = true;
  };
}
