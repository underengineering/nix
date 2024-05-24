{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkForce mkIf mkOption types;
  cfg = config.modules.wayland.vscodium;
in {
  options.modules.wayland.vscodium = {
    enable = mkOption {
      description = "Enable vscodium";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
    xdg.desktopEntries.codium = {
      name = "VSCodium";
      genericName = "Text Editor";
      icon = "vscodium";
      exec = mkForce "codium --enable-features=UseOzonePlatform --ozone-platform=wayland %F";
      terminal = false;
      categories = ["Utility" "TextEditor" "Development" "IDE"];
    };
  };
}
