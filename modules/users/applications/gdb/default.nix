{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.gdb;
in {
  options.modules.applications.gdb = {
    enable = mkOption {
      description = "Enable gdb";
      type = types.bool;
      default = true;
    };
    extraConfig = mkOption {
      description = "gdb configuration";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [pkgs.gdb];
    xdg.configFile."gdb/gdbinit".text = cfg.extraConfig;
  };
}
