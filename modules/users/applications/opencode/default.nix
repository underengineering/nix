{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.tmux;

  extraPackages = with pkgs; [
    # Plugin deps
    fastStdenv.cc
    fd
    imagemagick
    nodejs
    ripgrep

    # Markdown-preview
    yarn

    # Nix
    alejandra
    nil

    # Lua
    lua-language-server

    # Python
    black
    basedpyright
    ruff

    # C++ and C
    clang-tools

    # Golang
    gopls
    golangci-lint
    golangci-lint-langserver

    # Misc
    taplo
    yaml-language-server

    # Web
    prettier
    svelte-language-server
    typescript-language-server
    tailwindcss-language-server
    vscode-langservers-extracted
  ];
  opencode = pkgs.opencode.overrideAttrs (oldAttrs: {
    installPhase =
      oldAttrs.installPhase
      + ''
        wrapProgram $out/bin/opencode --suffix PATH : "${lib.makeBinPath extraPackages}"
      '';
  });
in {
  options.modules.applications.opencode = {
    enable = mkOption {
      description = "Enable opencode";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = [
      opencode
    ];

    # Fix playwright mcp (https://nixos.wiki/wiki/Playwright)
    home.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
    };
  };
}
