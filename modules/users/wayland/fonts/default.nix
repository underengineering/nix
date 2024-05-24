{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.fonts;
in {
  options.modules.wayland.fonts = {
    enable = mkOption {
      description = "Enable common fonts";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      dejavu_fonts
      iosevka
      lexend
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      powerline-symbols
      roboto
    ];
  };
}
