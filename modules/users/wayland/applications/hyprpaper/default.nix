{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) attrsets mkIf mkOption strings types;
  cfg = config.modules.wayland.hyprpaper;
in {
  options.modules.wayland.hyprpaper = {
    enable = mkOption {
      description = "Enable hyprpaper";
      type = types.bool;
      default = true;
    };
    ipc = mkOption {
      description = "Enable hyprpaper IPC";
      type = types.bool;
      default = false;
    };
    preload = mkOption {
      description = "List of images to preload";
      type = with types; listOf path;
      default = [];
    };
    wallpapers = mkOption {
      description = "List of wallpapers to show";
      type = with types; attrsOf path;
      default = {};
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      hyprpaper
    ];
    xdg.configFile."hypr/hyprpaper.conf" = with builtins; {
      text = ''
        ipc = ${
          if cfg.ipc
          then "on"
          else "off"
        }
        ${
          strings.concatMapStrings (path: "preload = ${path}\n") cfg.preload
        }
        ${
          strings.concatStrings (attrsets.mapAttrsToList (name: value: "wallpaper = ${name},${value}\n") cfg.wallpapers)
        }
      '';
    };
  };
}
