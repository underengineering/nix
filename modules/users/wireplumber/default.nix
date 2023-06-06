{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.wireplumber;
in {
  options.jd.wireplumber = {
    enable = mkOption {
      description = "Enable wireplumber configuration";
      type = types.bool;
      default = false;
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
    xdg.configFile."wireplumber/main.lua.d/51-nix-config.lua".text = cfg.mainConfig;
    xdg.configFile."wireplumber/bluetooth.lua.d/51-nix-config.lua".text = cfg.bluetoothConfig;
  };
}
