{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.applications;
in {
  options.jd.applications = {
    enable = mkOption {
      description = "Enable common applications";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      home-manager

      # CLI tools
      starship
      binutils
      sshfs
      fzf
    ];
  };
}
