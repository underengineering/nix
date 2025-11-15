{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge mkOption types;
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

      settings = mkMerge [
        {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
        }
        cfg.extraConfig
      ];
    };
  };
}
