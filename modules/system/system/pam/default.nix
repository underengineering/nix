{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.modules.system.pam;
in {
  options.modules.system.pam = {
    services = mkOption {
      default = {};
      type = with types; attrsOf attrs;
      description = lib.mdDoc ''
        This option defines the PAM services.  A service typically
        corresponds to a program that uses PAM,
        e.g. {command}`login` or {command}`passwd`.
        Each attribute of this set defines a PAM service, with the attribute name
        defining the name of the service.
      '';
    };
  };
  config = {
    security.pam.services = cfg.services;
  };
}
