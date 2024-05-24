{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.system.zram;
in {
  options.modules.system.zram = {
    enable = mkOption {
      description = "Enable ZRAM";
      type = types.bool;
      default = true;
    };
    algorithm = mkOption {
      description = "Compression algorithm";
      type = types.str;
      default = "zstd";
    };
    memoryPercent = mkOption {
      description = "Swap memory size in percent";
      type = types.int;
      default = 50;
    };
  };
  config = mkIf (cfg.enable) {
    zramSwap = {
      enable = true;
      algorithm = cfg.algorithm;
      memoryPercent = cfg.memoryPercent;
    };
  };
}
