{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.tmux;
in {
  options.modules.applications.opencode = {
    enable = mkOption {
      description = "Enable opencode";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      opencode
      playwright-driver.browsers
    ];

    # Fix playwright mcp (https://nixos.wiki/wiki/Playwright)
    home.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
      PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
    };
  };
}
