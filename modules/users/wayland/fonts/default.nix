{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
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
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      lexend
      roboto
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk
      iosevka
      powerline-symbols
      (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    ];
  };
}
