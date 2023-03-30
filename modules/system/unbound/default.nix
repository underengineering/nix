{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.unbound;
in
{
  options.jd.unbound = {
    enable = mkOption {
      description = "Enable unbound DNS client";
      type = types.bool;
      default = false;
    };
    forward-zone = mkOption {
      description = "Forward zones";
      type = with types; listOf (attrs);
      default = false;
    };
    overrideNameservers = mkOption {
      description = "Whether to override default nameservers";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable)
    {
      services.unbound = {
        enable = true;
        settings = {
          server = {
            interface = [ "127.0.0.1" ];
          };
          forward-zone = cfg.forward-zone;
        };
      };
      networking.nameservers = mkIf (cfg.overrideNameservers) [ "127.0.0.1" ];
    };
}
