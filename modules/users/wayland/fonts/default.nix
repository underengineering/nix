{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.fonts;
in {
  options.jd.fonts = {
    enable = mkOption {
      description = "Enable common fonts";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      roboto
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      powerline-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "NerdFontsSymbolsOnly" ]; })
    ];
  };
}
