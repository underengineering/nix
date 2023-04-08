{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.dunst;
in
{
  options.jd.dunst = {
    enable = mkOption {
      description = "Enable dunst";
      type = types.bool;
      default = false;
    };
    iconTheme = {
      package = mkOption {
        description = "The icon theme to use";
        type = with types; nullOr package;
        default = null;
      };
      name = mkOption {
        description = "Icon name";
        type = types.str;
        default = "";
      };
      size = mkOption {
        description = "Desired icon size";
        type = types.str;
        default = "32x32";
      };
    };
    settings = mkOption {
      description = "Dunst configuration";
      type = with types; attrsOf (attrsOf (either str (either bool (either int (listOf str)))));
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      libnotify
    ];
    services.dunst = {
      enable = true;
      iconTheme = cfg.iconTheme;
      settings = cfg.settings;
    };
  };
}
