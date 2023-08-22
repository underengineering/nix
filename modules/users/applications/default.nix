{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.applications;
in {
  options.jd.applications = {
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

      ffmpeg

      wireguard-tools

      # CLI tools
      ast-grep
      binutils
      btop
      delta
      du-dust
      duf
      exa
      fzf
      p7zip
      ripgrep
      rsync
      sshfs
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
    ./neovim
    ./zsh
    ./starship
  ];
}
