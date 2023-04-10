{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:underengineering/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay?rev=7070f17bb65146f9f6cff012c0321cbc9c8c8def";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      util = import ./lib {
        inherit inputs system nixpkgs pkgs home-manager hyprland lib; overlays = pkgs.overlays;
      };

      inherit (util) user;
      inherit (util) host;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.neovim-nightly-overlay.overlay
        ];
      };

      # Cursor names must be without spaces to be parsed correctly
      capitaine-cursors-themed = pkgs.capitaine-cursors-themed.overrideAttrs ({ preInstall ? "", ... }: {
        preInstall = preInstall + ''
          for src in *; do
            dst=$(echo "$src" | tr " " "-")
            mv "./$src" "$dst"
          done
        '';
      });

      system = "x86_64-linux";
    in
    {
      homeManagerConfigurations = {
        mika = user.mkHMUser {
          username = "mika";
          userConfig = {
            applications.enable = true;
            wezterm = {
              enable = true;
              config = builtins.readFile "${self}/config/wezterm.lua";
            };
            fonts.enable = true;
            git = {
              enable = true;
              userName = "underengineering";
              userEmail = "san4a852b@gmail.com";
            };
            wayland.enable = true;
            dunst = {
              enable = true;
              iconTheme = {
                package = pkgs.gruvbox-dark-icons-gtk;
                name = "oomox-gruvbox-dark";
              };
              settings = {
                global = {
                  font = "Fira Code 8";
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
            themes = {
              enable = true;
              cursorTheme = {
                enable = true;
                package = capitaine-cursors-themed;
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
                name = "Gruvbox-Dark";
              };
            };
          };
        };
      };

      nixosConfigurations = {
        lenowo = host.mkHost
          {
            name = "lenowo";
            kernelPackage = pkgs.linuxKernel.packages.linux_xanmod_latest;
            initrdMods = [ "amdgpu" "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
            kernelMods = [ "kvm-amd" ];
            kernelParams = [ "mitigations=off" ];
            systemConfig = {
              flatpak.enable = true;
              zram.enable = true;
              pipewire.enable = true;
              wayland.enable = true;
              bluetooth.enable = true;
              tlp.enable = true;
              chrony.enable = true;
              unbound = {
                enable = true;
                overrideNameservers = true;
                forward-zone = [
                  {
                    name = ".";
                    forward-addr = "77.91.85.64@853#dns.parsemyx.ml";
                    forward-tls-upstream = true;
                  }
                ];
              };
              greetd = {
                enable = true;
                command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r -t -c 'dbus-launch --sh-syntax --exit-with-session Hyprland'";
              };
            };
            users = [{
              name = "mika";
              groups = [ "audio" "video" "wheel" "wireshark" ];
              uid = 1000;
              shell = pkgs.zsh;
            }];
            cpuCores = 16;
          };
      };
    };
}
