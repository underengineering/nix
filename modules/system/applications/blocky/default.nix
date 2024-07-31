{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types getExe;
  cfg = config.modules.applications.blocky;
in {
  options.modules.applications.blocky = {
    enable = mkOption {
      description = "Enable blocky DNS client";
      type = types.bool;
      default = true;
    };
    config = mkOption {
      description = "Blocky configuration";
      type = types.path;
      default = {};
    };
  };
  config = mkIf (cfg.enable) {
    systemd.services.blocky = {
      description = "A DNS proxy and ad-blocker for the local network";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${getExe pkgs.blocky} --config ${cfg.config}";
        Restart = "on-failure";

        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
      };
    };
    networking.nameservers = ["127.0.0.1"];
  };
}
