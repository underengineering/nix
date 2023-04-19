{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.fonts;
in
{
  options.jd.fonts = {
    enable = mkOption {
      description = "Enable common fonts";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      roboto
      dejavu_fonts
      liberation_ttf
      noto-fonts
      fira-code
      fira-code-symbols
      powerline-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "NerdFontsSymbolsOnly" ]; })
    ];
  };
}
