{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.delta;
in {
  options.modules.applications.delta = {
    enable = mkOption {
      description = "Enable delta";
      type = types.bool;
      default = true;
    };
    options = mkOption {
      description = "Options to configure delta";
      type = with types; let
        primitiveType = either str (either bool int);
        sectionType = attrsOf primitiveType;
      in
        attrsOf (either primitiveType sectionType);
      default = {};
    };
  };
  config = mkIf (cfg.enable) {
    # In case git is not enabled
    home.packages = [pkgs.delta];
    programs.git.delta = {
      enable = true;
      options = cfg.options;
    };
  };
}
