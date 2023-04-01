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

      kitty

      # CLI tools
      starship
      sshfs
      
      # Fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      powerline-symbols
    ];
  };
}
