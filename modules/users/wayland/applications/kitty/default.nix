{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.kitty;
in {
  options.modules.wayland.kitty = {
    enable = mkOption {
      description = "Enable kitty";
      type = types.bool;
      default = true;
    };
    extraConfig = mkOption {
      description = "Kitty configuration";
      type = types.str;
      default = "";
    };
    ssh = {
      enable = mkOption {
        description = "Enable kitty ssh config";
        type = types.bool;
        default = false;
      };
      extraConfig = mkOption {
        description = "Kitty ssh configuration";
        type = types.str;
        default = "";
      };
    };
  };
  config = mkIf (cfg.enable) {
    xdg.configFile."kitty/ssh.conf" = mkIf (cfg.ssh.enable) {
      text = cfg.ssh.extraConfig;
    };
    programs.kitty = {
      enable = true;
      extraConfig = cfg.extraConfig;
    };
  };
}
