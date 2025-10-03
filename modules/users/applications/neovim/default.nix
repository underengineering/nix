{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.neovim;
in {
  options.modules.applications.neovim = {
    enable = mkOption {
      description = "Enable neovim";
      type = types.bool;
      default = true;
    };
    configPath = mkOption {
      description = "Path to the config";
      type = types.str;
    };
  };
  config = mkIf (cfg.enable) {
    xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/${cfg.configPath}";
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim;
      extraLuaPackages = luaPackages: [
        luaPackages.magick
      ];
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
        nodePackages_latest.prettier
        nodePackages_latest.svelte-language-server
        nodePackages_latest.typescript-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
      ];
      # Add codeium to PATH
      extraWrapperArgs = with pkgs; [
        "--suffix"
        "PATH"
        ":"
        "${codeium}/bin"
      ];
    };
  };
}
