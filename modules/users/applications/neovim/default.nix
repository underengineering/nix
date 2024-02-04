{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.neovim;
in {
  options.jd.neovim = {
    enable = mkOption {
      description = "Enable neovim";
      type = types.bool;
      default = false;
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
      package = pkgs.neovim-nightly;
      extraPackages = with pkgs; [
        # Plugin deps
        fd
        gcc
        nodejs

        # Markdown-preview
        stdenv.cc.cc.lib
        yarn

        # Nix
        alejandra
        nil

        # Lua
        lua-language-server

        # Python
        black
        nodePackages_latest.pyright
        ruff
        ruff-lsp

        # C++ and C
        clang-tools_17

        # Misc
        taplo
        yaml-language-server

        # Web
        nodePackages_latest."@prisma/language-server"
        nodePackages_latest.prettier
        nodePackages_latest.svelte-language-server
        nodePackages_latest.typescript-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
      ];
    };
  };
}
