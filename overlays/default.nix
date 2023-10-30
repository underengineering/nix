{
  inputs,
  pkgs,
  nixpkgs-staging,
  lib,
  ...
}:
with lib; {
  overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.hyprland.overlays.default
    inputs.hyprpaper.overlays.default
    (final: prev: {
      hyprland = inputs.hyprland.packages.${pkgs.system}.default.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = toString (old.NIX_CFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
        NIX_CXXFLAGS_COMPILE = toString (old.NIX_CXXFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
        NIX_LDFLAGS = toString (old.NIX_LDFLAGS or "") + " -flto=15";
      });

      # Cursor names must be without spaces to be parsed correctly
      capitaine-cursors-themed = prev.capitaine-cursors-themed.overrideAttrs ({preInstall ? "", ...}: {
        preInstall =
          preInstall
          + ''
            for src in *; do
              dst=$(echo "$src" | tr " " "-")
              mv "./$src" "$dst"
            done
          '';
      });

      # ISSUE: https://github.com/nix-community/neovim-nightly-overlay/issues/332
      neovim-nightly = prev.neovim-nightly.override {
        libvterm-neovim = nixpkgs-staging.legacyPackages.x86_64-linux.libvterm-neovim;
      };
      linux_xanmod_custom_lenowo = prev.linuxPackagesFor (prev.linux_xanmod_latest.override {
        structuredExtraConfig = with lib;
        with lib.kernel;
          {
            # From xanmod {{
            # Google's BBRv3 TCP congestion Control
            TCP_CONG_BBR = yes;
            DEFAULT_BBR = yes;

            # FQ-PIE Packet Scheduling
            NET_SCH_DEFAULT = yes;
            DEFAULT_FQ_PIE = yes;

            # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
            FUTEX = yes;
            FUTEX_PI = yes;

            # WineSync driver for fast kernel-backed Wine
            WINESYNC = module;

            # Preemptive Full Tickless Kernel at 500Hz
            HZ = freeform "500";
            HZ_500 = yes;
            HZ_1000 = no;
            # }}

            # Optimize for AMD
            MNATIVE_AMD = yes;

            # Use zstd for zram by default
            ZSWAP_COMPRESSOR_DEFAULT_ZSTD = yes;
            ZSWAP_COMPRESSOR_DEFAULT = freeform "zstd";

            # Disable AMDGPU CIK support
            CONFIG_DRM_AMDGPU_CIK = no;

            # Disable radeon drivers
            CONFIG_DRM_RADEON = no;
            CONFIG_FB_RADEON = no;
            CONFIG_FB_RADEON_I2C = no;
            CONFIG_FB_RADEON_BACKLIGHT = no;

            # Disable ngreedia drivers
            CONFIG_NET_VENDOR_NVIDIA = no;
            CONFIG_I2C_NVIDIA_GPU = no;
            CONFIG_FB_NVIDIA = no;
            CONFIG_FB_NVIDIA_I2C = no;
            CONFIG_FB_NVIDIA_BACKLIGHT = no;
            CONFIG_HID_NVIDIA_SHIELD = no;
            CONFIG_TYPEC_NVIDIA_ALTMODE = no;
            CONFIG_NVIDIA_WMI_EC_BACKLIGHT = no;

            # Disable mitigations
            SPECULATION_MITIGATIONS = no;
            STACKPROTECTOR_STRONG = no;

            # Disable SELinux
            SECURITY_SELINUX = no;

            # Reduce debug info
            DEBUG_INFO_REDUCED = mkForce yes;

            # Disable ms surface HID
            CONFIG_SURFACE_AGGREGATOR = no;

            # Disable unused wlan vendors
            WLAN_VENDOR_ADMTEK = no;
            WLAN_VENDOR_ATH = no;
            WLAN_VENDOR_ATMEL = no;
            WLAN_VENDOR_BROADCOM = no;
            WLAN_VENDOR_CISCO = no;
            WLAN_VENDOR_INTEL = no;
            WLAN_VENDOR_INTERSIL = no;
            WLAN_VENDOR_MARVELL = no;
            WLAN_VENDOR_MEDIATEK = yes;
            WLAN_VENDOR_MICROCHIP = no;
            WLAN_VENDOR_PURELIFI = no;
            WLAN_VENDOR_RALINK = no;
            WLAN_VENDOR_REALTEK = no;
            WLAN_VENDOR_RSI = no;
            WLAN_VENDOR_SILABS = no;
            WLAN_VENDOR_ST = no;
            WLAN_VENDOR_TI = no;
            WLAN_VENDOR_ZYDAS = no;
            WLAN_VENDOR_QUANTENNA = no;

            # Disable unused SOC modules
            SND_SOC_CHV3_I2S = no;
            SND_SOC_ADI = no;
            SND_SOC_APPLE_MCA = no;
            SND_ATMEL_SOC = no;
            SND_DESIGNWARE_I2S = no;
            SND_SOC_FSL_ASRC = no;
            SND_SOC_FSL_SAI = no;
            SND_SOC_FSL_MQS = no;
            SND_SOC_FSL_AUDMIX = no;
            SND_SOC_FSL_SSI = no;
            SND_SOC_FSL_SPDIF = no;
            SND_SOC_FSL_ESAI = no;
            SND_SOC_FSL_MICFIL = no;
            SND_SOC_FSL_EASRC = no;
            SND_SOC_FSL_XCVR = no;
            SND_SOC_FSL_UTILS = no;
            SND_SOC_FSL_RPMSG = no;
            SND_I2S_HI6210_I2S = no;
            SND_SOC_IMG = no;
            SND_SOC_STI = no;
            SND_SOC_XILINX_I2S = no;
            SND_SOC_XILINX_AUDIO_FORMATTER = no;
            SND_SOC_XILINX_SPDIF = no;
            SND_XEN_FRONTEND = no;
          }
          // prev.linux_xanmod_latest.structuredExtraConfig;
        ignoreConfigErrors = true;
      });
    })
  ];
}
