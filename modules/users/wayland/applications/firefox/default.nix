{inputs}: {
  self,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.firefox;
in {
  options.jd.firefox = {
    enable = mkOption {
      description = "Enable firefox";
      type = types.bool;
      default = false;
    };
    package = mkOption {
      description = "Firefox package to use";
      type = types.package;
      default = pkgs.firefox;
    };
    extraConfig = mkOption {
      description = "Config that will be appended after arkenfox";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    programs.firefox = {
      enable = true;
      package = cfg.package;
      profiles.main = {
        extraConfig = (builtins.readFile "${inputs.arkenfox}/user.js") + cfg.extraConfig;
      };
    };
  };
}
