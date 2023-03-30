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
            git.enable = true;
            hyprland.enable = true;
          };
        };
      };

      nixosConfigurations = {
        test = host.mkHost {
          name = "test-vm";
          NICs = [ "enp1s0" ];
          kernelPackage = pkgs.linuxKernel.packages.linux_xanmod_latest;
          initrdMods = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
          kernelMods = [ "kvm-intel" ];
          kernelParams = [ ];
          systemConfig = {
            ssh.enable = true;
            ssh.type = "server";
            #kernel = {
            #  enablePatches = true;
            #  cpuVendor = "intel";
            #  disableMitigations = true;
            #};
            greetd = {
              enable = true;
              command = "${pkgs.greetd.greetd}/bin/agreety -c sh";
            };
            unbound = {
              enable = true;
              forward-zone = [
                {
                  name = ".";
                  forward-addr = "77.91.85.64@853#dns.parsemyx.ml";
                  forward-tls-upstream = true;
                }
              ];
            };
          };
          users = [{
            name = "mika";
            groups = [ "wheel" ];
            uid = 1000;
            shell = pkgs.zsh;
          }];
          cpuCores = 4;
        };
      };
    };
}
