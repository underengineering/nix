{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.vscodium;
in {
  options.modules.vscodium = {
    enable = mkOption {
      description = "Enable vscodium";
      type = types.bool;
      default = false;
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
