{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:underengineering/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      util = import ./lib {
        inherit inputs system nixpkgs pkgs home-manager nixos-hardware hyprland lib; overlays = pkgs.overlays;
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
            git.enable = true;
            wayland.enable = true;
            hyprland = {
              enable = true;
              extraConfig = builtins.readFile "${self}/config/hyprland.conf";
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
              zram.enable = true;
              pipewire.enable = true;
              wayland.enable = true;
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
