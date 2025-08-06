{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.git;
in {
  options.modules.applications.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = true;
    };
    userName = mkOption {
      description = "Git username";
      type = types.str;
      default = "John Doe";
    };
    userEmail = mkOption {
      description = "Git email";
      type = types.str;
      default = "john-doe@gmail.com";
    };
    extraConfig = mkOption {
      description = "";
      default = {};
    };
  };
  config = mkIf (cfg.enable) {
    programs.git = {
      enable = true;
      lfs.enable = true;

      userName = cfg.userName;
      userEmail = cfg.userEmail;
      extraConfig = cfg.extraConfig;
    };
  };
}
