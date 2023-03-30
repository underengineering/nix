{ inputs, user, lib, system, pkgs, ... }:
with builtins;
{
  mkHost =
    { name
    , NICs
    , initrdMods
    , kernelMods
    , kernelParams
    , kernelPackage
    , systemConfig
    , cpuCores
    , users
    , wifi ? [ ]
    , gpuTempSensor ? null
    , cpuTempSensor ? null
    }:
    let
      networkCfg = listToAttrs (map
        (iface: {
          name = "${iface}";
          value = { useDHCP = true; };
        })
        NICs);

      userCfg = {
        inherit name NICs systemConfig cpuCores gpuTempSensor cpuTempSensor;
      };

      sysUsers = map (u: user.mkSystemUser u) users;
    in
    lib.nixosSystem {
      inherit system;

      modules = [
        {
          imports = [ ../modules/system ] ++ sysUsers;
          jd = systemConfig;
          environment.etc = {
            "hmsystemdata.json".text = toJSON userCfg;
          };

          networking.hostName = name;
          networking.interfaces = networkCfg;
          networking.wireless.interfaces = wifi;

          networking.networkmanager.enable = true;
          networking.useDHCP = false;

          boot.initrd.availableKernelModules = initrdMods;
          boot.kernelModules = kernelMods;
          boot.kernelParams = kernelParams;
          boot.kernelPackages = kernelPackage;

          nixpkgs.pkgs = pkgs;

          nix.settings = {
            max-jobs = lib.mkDefault cpuCores;
            experimental-features = [ "flakes" "nix-command" ];
            substituters = [
              "https://cache.nixos.org"
              "https://hyprland.cachix.org"
            ];
            trusted-public-keys = [
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            ];
          };

          system.stateVersion = "23.05";
        }
      ];
    };
}
