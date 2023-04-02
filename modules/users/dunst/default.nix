{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.dunst;
in {
  options.jd.dunst = {
    enable = mkOption {
      description = "Enable dunst";
      type = types.bool;
      default = false;
    };
    settings = mkOption {
      description = "Dunst configuration";
      type = with types; attrsOf (attrs);
      default = {};
    };
  };
  config = mkIf (cfg.enable) {
    services.dunst = {
      enable = true;
      settings = cfg.settings;
    };
  };
}
