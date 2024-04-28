{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.applications;
in {
  options.modules.applications = {
    enable = mkOption {
      description = "Enable common applications";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    # Manage bash with home-manager
    programs.bash.enable = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home.packages = with pkgs; [
      home-manager
      nh

      ffmpeg

      wireguard-tools

      distrobox

      # CLI tools
      ast-grep
      binutils
      btop
      du-dust
      duf
      duplicacy
      eza
      file
      fzf
      jq
      lazygit
      p7zip
      ripgrep
      rsync
      sshfs
      swayidle
      tesseract
      unar
      unzip
      zip
      zstd

      # Various interpreters
      luajit
      nodePackages.pnpm
      nodejs
      python3
    ];
  };
  imports = [
    ./delta
    ./neovim
    ./zsh
    ./starship
    ./lazygit
    ./tmux
  ];
}
