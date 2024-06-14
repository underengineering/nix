{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.keyd;
in {
  options.modules.applications.keyd = {
    enable = mkOption {
      description = "Enable keyd";
      type = types.bool;
      default = true;
    };
    keyboards = mkOption {
      description = "Configuration for keyboards";
      type = types.attrs;
      default = {
        default = {
          ids = ["*"];
          settings.main = {
            capslock = "overload(control, esc)";
            esc = "capslock";
          };
        };
      };
    };
  };
  config = mkIf (cfg.enable) {
    services.keyd = {
      enable = true;
      keyboards = cfg.keyboards;
    };
  };
}
