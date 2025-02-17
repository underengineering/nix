{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fzf-runner = {
      url = "github:underengineering/fzf-runner";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crabbar = {
      url = "github:underengineering/crabbar";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:underengineering/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    shyfox = {
      url = "github:Naezr/ShyFox";
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
    homeConfigurations = rec {
      mika = user.mkHMUser {
        username = "mika";
        userConfig = {
          applications = {
            enable = true;

            starship.extraConfig = builtins.readFile "${self}/config/starship.toml";
            neovim.configPath = "config/nvim";
            zsh.initExtra = builtins.readFile "${self}/config/.zshrc";
            gdb.extraConfig = builtins.readFile "${self}/config/.gdbinit";
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

            crabbar = {
              config = {
                margins = {
                  top = 2;
                };
                image_path = "${self}/config/crabbar/nix-snowflake.svg";
                network_name = "wlp4s0";
                battery_name = "BAT0";
                layout_map = {
                  "English (US)" = "EN";
                  "Russian" = "RU";
                };
              };
              cssConfig = builtins.readFile "${self}/config/crabbar/style.css";
            };
            kitty = {
              extraConfig = builtins.readFile "${self}/config/kitty/kitty.conf";
              ssh = {
                enable = true;
                extraConfig = builtins.readFile "${self}/config/kitty/ssh.conf";
              };
            };
            firefox = {
              package = pkgs.firefox-beta;
              extraConfig = builtins.readFile "${self}/config/firefox/user.js";
              extraUserChrome = builtins.readFile "${self}/config/firefox/userChrome.css";
            };
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
      mika-pc = lib.recursiveUpdate mika {
        userConfig = {
          applications = {
            enable = true;

            starship.extraConfig = builtins.readFile "${self}/config/starship.toml";
            neovim.configPath = "config/nvim";
            zsh.initExtra = builtins.readFile "${self}/config/.zshrc";
            gdb.extraConfig = builtins.readFile "${self}/config/.gdbinit";
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
          };
          wayland.enable = false;
        };
      };
    };

    nixosConfigurations = {
      pc =
        host.mkHost
        {
          name = "pcpc";
          kernelPackage = pkgs.linux_latest;
          initrdMods = ["amdgpu" "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
          kernelMods = ["kvm-intel"];
          kernelParams = [
            "mitigations=off"
            "nowatchdog"
          ];
          systemConfig = {
            system = {
              pam.services.swaylock.text = "auth include login";
              udev.extraRules = builtins.readFile "${self}/config/udev/60-steam-input.rules";
            };
            wayland.enable = true;
            applications = {
              blocky.config = ./config/blocky.yaml;
              greetd.command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r -t -c Hyprland";
              ssh.withServer = true;
              tlp.enable = false;
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
                    name = "X86_64_NATIVE";
                    patch = ./patches/kernel/native.patch;
                  }
                  {
                    name = "BORE";
                    patch = ./patches/kernel/bore-6.13.patch;
                  }
                ];
              };
              pam.services.swaylock.text = "auth include login";
              udev.extraRules = builtins.readFile "${self}/config/udev/60-steam-input.rules";
            };
            wayland = {
              enable = true;

              applications.hyprland.enable = true;
            };
            applications = {
              bluetooth.enable = true;
              greetd.command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r -t -c Hyprland";
              blocky.config = ./config/blocky.yaml;
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
