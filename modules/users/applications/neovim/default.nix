{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.neovim;
in
{
  options.jd.neovim = {
    enable = mkOption {
      description = "Enable neovim";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
    };
  };
}
