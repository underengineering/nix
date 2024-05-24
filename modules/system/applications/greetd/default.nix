{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.greetd;
in {
  options.modules.applications.greetd = {
    enable = mkOption {
      description = "Enable greetd";
      type = types.bool;
      default = true;
    };
    command = mkOption {
      description = "Command to run";
      type = types.str;
    };
  };
  config = mkIf (cfg.enable) {
    services.greetd = {
      enable = true;
      restart = true;
      vt = 7;
      settings.default_session = {
        command = cfg.command;
        user = "greeter";
      };
    };
  };
}
