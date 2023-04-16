{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.themes;
in
{
  options.jd.themes = {
    enable = mkOption {
      description = "Enable themes module";
      type = types.bool;
      default = false;
    };
    cursorTheme = {
      enable = mkOption {
        description = "Enable cursor theme";
        type = types.bool;
        default = false;
      };
      package = mkOption {
        description = "Cursor package";
        type = with types; nullOr package;
        default = null;
      };
      name = mkOption {
        description = "Cursor name";
        type = types.str;
        default = "";
      };
      size = mkOption {
        description = "Cursor size";
        type = with types; nullOr int;
        default = null;
      };
    };
    iconTheme = {
      enable = mkOption {
        description = "Enable icon theme";
        type = types.bool;
        default = false;
      };
      package = mkOption {
        description = "Icon package";
        type = with types; nullOr package;
        default = null;
      };
      name = mkOption {
        description = "Icon theme name";
        type = types.str;
        default = "";
      };
    };
    theme = {
      enable = mkOption {
        description = "Enable theme";
        type = types.bool;
        default = false;
      };
      package = mkOption {
        description = "Theme package";
        type = with types; nullOr package;
        default = null;
      };
      name = mkOption {
        description = "Theme name";
        type = types.str;
        default = "";
      };
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      dconf
    ];
    home.pointerCursor = mkIf (cfg.cursorTheme.enable) {
      gtk.enable = true;
      x11.enable = true;
      package = cfg.cursorTheme.package;
      name = cfg.cursorTheme.name;
      size = cfg.cursorTheme.size;
    };
    gtk = {
      enable = true;
      iconTheme = mkIf (cfg.iconTheme.enable) {
        package = cfg.iconTheme.package;
        name = cfg.iconTheme.name;
      };
      theme = mkIf (cfg.theme.enable) {
        package = cfg.theme.package;
        name = cfg.theme.name;
      };
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "gtk2";
    };
  };
}
