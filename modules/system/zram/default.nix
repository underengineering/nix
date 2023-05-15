{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.zram;
in {
  options.jd.zram = {
    enable = mkOption {
      description = "Enable ZRAM";
      type = types.bool;
      default = false;
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
