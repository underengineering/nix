{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.applications;
in
{
  options.jd.applications = {
    enable = mkOption {
      description = "Enable common applications";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    # Manage bash with home-manager
    programs.bash.enable = true;
    home.packages = with pkgs; [
      home-manager

      ffmpeg

      # CLI tools
      starship
      binutils
      sshfs
      fzf
    ];
  };
  imports = [
    ./neovim
    ./zsh
    ./starship
  ];
}
