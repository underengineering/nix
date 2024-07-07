{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.modules.system.udev;
in {
  options.modules.system.udev = {
    extraRules = mkOption {
      default = "";
      type = types.str;
      description = "Additional `udev` rules. They’ll be written into file 99-local.rules. Thus they are read and applied after all other rules.";
    };
  };
  config = {
    services.udev.extraRules = cfg.extraRules;
  };
}
