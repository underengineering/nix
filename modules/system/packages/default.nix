{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.jd.packages;
in
{
  config = {
    environment.systemPackages = with pkgs; [
      # Coreutils replacements
      exa
      delta
      du-dust
      duf
      ripgrep
      btop

      # Text editors
      vim
      neovim

      # Utils
      nmap
      fzf
      unzip
      zstd
      p7zip
    ];
  };
}
