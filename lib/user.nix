{
  inputs,
  pkgs,
  home-manager,
  hyprland,
  lib,
  system,
  overlays,
  ...
}:
with builtins; {
  mkHMUser = {
    userConfig,
    username,
  }: let
    trySettings = tryEval (fromJSON (readFile /etc/hmsystemdata.json));
    machineData =
      if trySettings.success
      then trySettings.value
      else {};

    machineModule = {
      pkgs,
      config,
      lib,
      ...
    }: {
      options.machineData = lib.mkOption {
        default = {};
        description = "Settings passed from nixos system configuration. If not present will be empty";
      };
      config.machineData = machineData;
    };
  in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        (import ../modules/users {inherit inputs;})
        machineModule
        hyprland.homeManagerModules.default
        {
          jd = userConfig;
          nixpkgs = {
            overlays = overlays;
            config = {
              allowUnfree = true;
            };
          };
          home = {
            inherit username;
            stateVersion = "23.05";
            homeDirectory = "/home/${username}";
          };
          systemd.user.startServices = true;
        }
      ];
    };

  mkSystemUser = {
    name,
    groups,
    uid,
    shell,
    ...
  }: {
    users.users."${name}" = {...}: {
      name = name;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      uid = uid;
      initialPassword = "asdasd123";
      shell = shell;
    };
  };
}
