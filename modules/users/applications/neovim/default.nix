{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.neovim;
in
{
  options.jd.neovim = {
    enable = mkOption {
      description = "Enable neovim";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      extraPackages = with pkgs; [
        # Nix
        nil
        nixpkgs-fmt

        # Lua
        lua-language-server

        # Python
        ruff
        nodejs
        nodePackages_latest.pyright
        black

        # C++ and C
        clang-tools_15

        # Web
        nodePackages_latest.typescript-language-server
        nodePackages_latest.prettier
        nodePackages_latest.vscode-langservers-extracted
      ];
    };
  };
}
