{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.jd.packages;
in
{
  config = {
    programs.zsh.enable = true;
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
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
      neovim-nightly

      # Utils
      nmap
      fzf
      unzip
      zstd
      p7zip
    ];
  };
}
