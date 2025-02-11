{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.modules.applications.ssh;
in {
  options.modules.applications.ssh = {
    enable = mkOption {
      description = "Whether to enable ssh";
      type = types.bool;
      default = true;
    };
    withServer = mkOption {
      description = "Enable openssh service";
      type = types.bool;
      default = false;
    };
  };
  config = mkMerge [
    (mkIf (cfg.withServer) {
      services.openssh.openFirewall = true;
      services.openssh = {
        enable = true;
      };
    })
  ];
}
