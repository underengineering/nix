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
    type = mkOption {
      description = "Whether is ssh client or server";
      type = types.enum ["client" "server"];
      default = "client";
    };
  };
  config = mkMerge [
    (mkIf (cfg.type == "server") {
      services.openssh.openFirewall = true;
      services.openssh = {
        enable = true;
      };
    })
  ];
}
