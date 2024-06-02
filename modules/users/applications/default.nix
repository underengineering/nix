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

    services.syncthing.enable = true;
    systemd.user.services.syncthing.Install.WantedBy = mkForce [];

    home.packages = with pkgs; [
      # Nix tools
      home-manager
      nh

      #  Media tools
      ffmpeg

      # Network tools
      duplicacy
      rsync
      sing-box
      sshfs
      wireguard-tools

      # CLI tools
      ast-grep
      binutils
      btop
      distrobox
      du-dust
      duf
      eza
      file
      fzf
      fzf-runner
      jq
      lazygit
      p7zip
      ripgrep
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
    ./git
    ./lazygit
    ./neovim
    ./starship
    ./tmux
    ./wireplumber
    ./zsh
  ];
}
