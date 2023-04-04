{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:underengineering/Hyprland";
    xdph.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
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
        overlays = [ ];
      };

      system = "x86_64-linux";
    in
    {
      homeManagerConfigurations = {
        mika = user.mkHMUser {
          username = "mika";
          userConfig = {
            applications.enable = true;
            fonts.enable = true;
            git = {
              enable = true;
              userName = "underengineering";
              userEmail = "san4a852b@gmail.com";
            };
            wayland.enable = true;
            dunst.enable = true;
            hyprland = {
              enable = true;
              extraConfig = builtins.readFile "${self}/config/hyprland.conf";
            };
            themes = {
              enable = true;
              cursorTheme = {
                enable = true;
                package = pkgs.capitaine-cursors-themed;
                name = "Capitaine Cursors (Gruvbox)";
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
                command = "${pkgs.greetd.greetd}/bin/agreety -c 'dbus-launch --sh-syntax --exit-with-session Hyprland'";
              };
            };
            users = [{
              name = "mika";
              groups = [ "audio" "video" "wheel" ];
              uid = 1000;
              shell = pkgs.zsh;
            }];
            cpuCores = 16;
          };
      };
    };
}
