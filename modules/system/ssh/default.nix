{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.ssh;
in {
  options.modules.ssh = {
    enable = mkOption {
      description = "Whether to enable ssh";
      type = types.bool;
      default = false;
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
