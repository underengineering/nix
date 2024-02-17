{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.greetd;
in {
  options.modules.greetd = {
    enable = mkOption {
      description = "Enable greetd";
      type = types.bool;
      default = false;
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
