{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.jd.git;
in
{
  options.jd.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = false;
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
  };
  config = mkIf (cfg.enable) {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
    };
  };
}
