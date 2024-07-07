{ config, inputs, lib, pkgs, profiles, ... }:
{
  imports = with profiles; [
    core
    display
    japanese
    syncthing
  ];

  boot = {
    # kernelParams = [ "quiet" ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 6;
    };
    # plymouth.enable = true;
  };
  services.fstrim.enable = true; # SSDs are the new normal

  networking.networkmanager.wifi.powersave = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  powerManagement = { powertop.enable = true; };
  services.auto-cpufreq.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      START_CHARGE_THRESH_BAT0="60";
      STOP_CHARGE_THRESH_BAT0="80";
    };
  };
  services.thinkfan.enable = true;

  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      # Enable or disable the script execution
      Enabled: True
      # SYSFS path for checking if the system is running on AC power
      Sysfs_Power_Path: /sys/class/power_supply/AC*/online

      ## Settings to apply while connected to Battery power
      [BATTERY]
      # Update the registers every this many seconds
      Update_Rate_s: 30
      # Max package power for time window #1
      PL1_Tdp_W: 29
      # Time window #1 duration
      PL1_Duration_s: 28
      # Max package power for time window #2
      PL2_Tdp_W: 44
      # Time window #2 duration
      PL2_Duration_S: 0.002
      # Max allowed temperature before throttling
      Trip_Temp_C: 85
      # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
      cTDP: 1

      ## Settings to apply while connected to AC power
      [AC]
      # Update the registers every this many seconds
      Update_Rate_s: 5
      # Max package power for time window #1
      PL1_Tdp_W: 44
      # Time window #1 duration
      PL1_Duration_s: 28
      # Max package power for time window #2
      PL2_Tdp_W: 44
      # Time window #2 duration
      PL2_Duration_S: 0.002
      # Max allowed temperature before throttling
      Trip_Temp_C: 95
      # Set HWP energy performance hints to 'performance' on high load (EXPERIMENTAL)
      HWP_Mode: True
      # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
      cTDP: 2

      [UNDERVOLT]
      # CPU core voltage offset (mV)
      CORE: -200
      # Integrated GPU voltage offset (mV)
      GPU: -60
      # CPU cache voltage offset (mV)
      CACHE: -50
      # System Agent voltage offset (mV)
      UNCORE: 0
      # Analog I/O voltage offset (mV)
      ANALOGIO: 0
    '';
  };
}
