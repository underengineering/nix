{
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; {
  overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.hyprland.overlays.default
    inputs.hyprpaper.overlays.default
    (final: prev: {
      hyprland-lto = inputs.hyprland.packages.${pkgs.system}.default.overrideAttrs (old: {
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

      linux_xanmod_custom_lenowo = prev.linuxPackagesFor (prev.linux_xanmod_latest.override {
        structuredExtraConfig = with lib;
        with lib.kernel;
          {
            # Optimize for AMD
            MNATIVE_AMD = yes;

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
          }
          // prev.linux_xanmod_latest.structuredExtraConfig;
        ignoreConfigErrors = true;
      });
    })
  ];
}
