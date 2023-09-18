{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:underengineering/Hyprland";
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
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake = {
      url = "github:neovim/neovim/nightly?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.neovim-flake.follows = "neovim-flake";
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
    inherit (nixpkgs) lib;
    util = import ./lib {
      inherit inputs system nixpkgs pkgs home-manager hyprland lib;
      overlays = pkgs.overlays;
    };

    inherit (util) user;
    inherit (util) host;

    pkgs = import nixpkgs {
      inherit system;
      inherit ((import ./overlays {inherit inputs system nixpkgs pkgs lib;})) overlays;
      config.allowUnfree = true;
    };

    system = "x86_64-linux";
  in {
    homeManagerConfigurations = {
      mika = user.mkHMUser {
        username = "mika";
        userConfig = {
          applications.enable = true;
          wezterm = {
            enable = true;
            config = builtins.readFile "${self}/config/wezterm.lua";
          };
          starship = {
            enable = true;
            extraConfig = builtins.readFile "${self}/config/starship.toml";
          };
          firefox = {
            enable = true;
            package = pkgs.firefox-beta;
            extraConfig = builtins.readFile "${self}/config/firefox.js";
          };
          crabshell.enable = true;
          neovim.enable = true;
          zsh = {
            enable = true;
            initExtra = builtins.readFile "${self}/config/.zshrc";
          };
          fonts.enable = true;
          git = {
            enable = true;
            userName = "underengineering";
            userEmail = "san4a852b@gmail.com";
          };
          wayland.enable = true;
          vscodium.enable = true;
          dunst = {
            enable = true;
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
          hyprland = {
            enable = true;
            extraConfig = builtins.readFile "${self}/config/hyprland.conf";
          };
          hyprpaper = {
            enable = true;
            ipc = false;
            preload = ["${self}/wallpapers/wallpaper.png"];
            wallpapers = {
              eDP-2 = "${self}/wallpapers/wallpaper.png";
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
              package = pkgs.gruvbox-gtk-theme;
              name = "Gruvbox-Dark-BL";
            };
          };
          wireplumber = {
            enable = true;
            bluetoothConfig = builtins.readFile "${self}/config/wireplumber/bluetooth.lua";
          };
        };
      };
    };

    nixosConfigurations = {
      lenowo =
        host.mkHost
        {
          name = "lenowo";
          kernelPackage = pkgs.linuxKernel.packages.linux_xanmod_latest;
          initrdMods = ["amdgpu" "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
          kernelMods = ["kvm-amd"];
          kernelParams = ["mitigations=off" "initcall_blacklist=acpi_cpufreq" "amd_pstate=active" "nowatchdog"];
          systemConfig = {
            kernel = {
              enablePatches = true;
              cpuVendor = "amd";
              patches = [
                {
                  name = "Lenovo sound patch";
                  patch = "${self}/patches/kernel/lenovo-sound.patch";
                }
              ];
            };
            flatpak.enable = true;
            zram.enable = true;
            pipewire.enable = true;
            wayland.enable = true;
            bluetooth.enable = true;
            tlp.enable = true;
            chrony.enable = true;
            pam.services.swaylock.text = "auth include login";
            unbound = {
              enable = true;
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
            greetd = {
              enable = true;
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r -t -c Hyprland";
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
