{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.applications.wireplumber;
in {
  options.modules.applications.wireplumber = {
    enable = mkOption {
      description = "Enable wireplumber configuration";
      type = types.bool;
      default = true;
    };
    mainConfig = mkOption {
      description = "Wireplumber config file";
      type = types.str;
      default = "";
    };
    bluetoothConfig = mkOption {
      description = "Bluetooth config file";
      type = types.str;
      default = "";
    };
  };
  config = mkIf (cfg.enable) {
    xdg.configFile."wireplumber/bluetooth.lua.d/51-nix-config.lua".text = cfg.bluetoothConfig;
    xdg.configFile."wireplumber/main.lua.d/51-nix-config.lua".text = cfg.mainConfig;
  };
}
