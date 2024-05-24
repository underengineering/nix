{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.xdph.follows = "xdph";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crabshell = {
      url = "github:underengineering/crabshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.utils.follows = "flake-utils";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    inherit (nixpkgs) lib;
    pkgs = import nixpkgs {
      inherit system;
      inherit ((import ./overlays {inherit inputs system nixpkgs pkgs lib;})) overlays;
      config.allowUnfree = true;
    };

    util = import ./lib {
      inherit inputs system nixpkgs pkgs home-manager hyprland lib;
      overlays = pkgs.overlays;
    };

    inherit (util) user;
    inherit (util) host;
  in {
    homeConfigurations = {
      mika = user.mkHMUser {
        username = "mika";
        userConfig = {
          applications = {
            enable = true;

            starship.extraConfig = builtins.readFile "${self}/config/starship.toml";
            neovim.configPath = "config/nvim";
            zsh.initExtra = builtins.readFile "${self}/config/.zshrc";
            git = {
              userName = "underengineering";
              userEmail = "san4a852b@gmail.com";
              extraConfig = {
                core.sshCommand = "ssh-session";
              };
            };
            delta.options = {
              syntax-theme = "gruvbox-dark";
            };
            lazygit.extraConfig = builtins.readFile "${self}/config/lazygit.yml";
            tmux.configPath = "config/tmux";
            wireplumber.bluetoothConfig = builtins.readFile "${self}/config/wireplumber/bluetooth.lua";
          };
          wayland = {
            enable = true;

            kitty = {
              extraConfig = builtins.readFile "${self}/config/kitty/kitty.conf";
              ssh = {
                enable = true;
                extraConfig = builtins.readFile "${self}/config/kitty/ssh.conf";
              };
            };
            firefox = {
              package = pkgs.firefox-beta;
              extraConfig = builtins.readFile "${self}/config/firefox.js";
            };
            crabshell.configPath = "config/crabshell";
            dunst = {
              iconTheme = {
                package = pkgs.gruvbox-dark-icons-gtk;
                name = "oomox-gruvbox-dark";
              };
              settings = {
                global = {
                  font = "Lexend 9";
                  corner_radius = 4;
                  frame_width = 1;
                  gap_size = 4;

                  foreground = "#ebdbb2";
                  background = "#3c38361f";
                  highlight = "#ebdbb2";
                };
                urgency_low = {
                  urgency = "low";
                  frame_color = "#458588";
                };
                urgency_normal = {
                  urgency = "normal";
                  frame_color = "#98971a";
                };
                urgency_critical = {
                  urgency = "critical";
                  frame_color = "#cc241d";
                };
              };
            };
            hyprland.extraConfig = builtins.readFile "${self}/config/hyprland.conf";
            hyprpaper = let
              wallpaper-path = "${self}/wallpapers/e7d53cc7bac3a63a79b25e1bac7b776f0678d234_s2_n1_y1.png";
            in {
              ipc = false;
              preload = [wallpaper-path];
              wallpapers = {
                eDP-2 = wallpaper-path;
              };
            };
            themes = {
              enable = true;
              cursorTheme = {
                enable = true;
                package = pkgs.capitaine-cursors-themed;
                name = "Capitaine-Cursors-(Gruvbox)";
                size = 32;
              };
              iconTheme = {
                enable = true;
                package = pkgs.gruvbox-dark-icons-gtk;
                name = "oomox-gruvbox-dark";
              };
              theme = {
                enable = true;
                package = pkgs.orchis-theme-gruvbox;
                name = "Orchis-Green-Dark";
              };
            };
          };
        };
      };
    };

    nixosConfigurations = {
      lenowo =
        host.mkHost
        {
          name = "lenowo";
          kernelPackage = pkgs.linux_custom_lenowo;
          initrdMods = ["amdgpu" "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
          kernelMods = ["kvm-amd"];
          kernelParams = [
            "mitigations=off"
            "initcall_blacklist=acpi_cpufreq"
            "amd_pstate=active"
            "nowatchdog"
          ];
          systemConfig = {
            system = {
              kernel = {
                patches = [
                  {
                    name = "Lenovo sound patch";
                    patch = "${self}/patches/kernel/lenovo-sound-6.8.patch";
                  }
                  {
                    name = "BORE";
                    patch = "${self}/patches/kernel/bore-6.9.patch";
                  }
                ];
              };
              pam.services.swaylock.text = "auth include login";
            };
            wayland = {
              enable = true;
            };
            applications = {
              bluetooth.enable = true;
              greetd.command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r -t -c Hyprland";
              unbound = {
                overrideNameservers = true;
                forward-zone = [
                  {
                    name = ".";
                    forward-addr = [
                      "94.228.168.12@853#dns.libpcap.ru"
                      "1.1.1.1@853"
                      "1.0.0.1@853"
                    ];
                    forward-tls-upstream = true;
                  }
                ];
              };
            };
          };
          users = [
            {
              name = "mika";
              groups = ["audio" "video" "wheel" "wireshark" "libvirtd"];
              uid = 1000;
              shell = pkgs.zsh;
            }
          ];
          cpuCores = 16;
        };
    };
  };
}
