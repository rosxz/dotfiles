{ config, pkgs, user, ... }: {
  # services.seatd.enable = true;

  # amdgpu.virtual_display reference:
  # https://github.com/torvalds/linux/blob/63849c8f410717eb2e6662f3953ff674727303e7/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c#L452
  boot.kernelParams = [ "amdgpu.virtual_display=0000:09:00.0,1" ];
  # Assuming uinput has already been added to boot.kernelModules
  services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0666", OPTIONS+="static_node=uinput"
  '';

  services.xserver = {
    config = ''
Section "Device"
    Identifier "AMD 5700XT"
    Driver "amdgpu"
    Option "AccelMethod" "glamor"
    Option "TearFree" "on"
    Option "DRI" "3"
    BusID "PCI:09:00"
EndSection
'';
    modules = with pkgs.xorg; [
      xf86videoamdgpu
      xf86inputlibinput
      xf86videovesa
    ];
    displayManager.autoLogin = {
      user = "${user}";
      enable = true;
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = config.modules.labels.display == "wayland";
    openFirewall = true;
  };

#==
# Using xorg.xf86videodummy module (need to add to list!)
# Leaving this here as it might be neeed one day
# Reference: https://bbs.archlinux.org/viewtopic.php?id=297503
#==

#    config = ''
#Section "Monitor"
#        Identifier "My-virtual-amdgpu-output"
#        HorizSync 28.0-80.0
#        VertRefresh 48.0-75.0
#        Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
#EndSection
#
#Section "OutputClass"
#	Identifier	"AMDgpu"
#	MatchDriver	"amdgpu"
#	Driver		"amdgpu"
#	Option		"My-virtual-amdgpu-output"
#EndSection
#
#Section "Screen"
#        Identifier "dummy_screen"
#        Device "AMDgpu"
#        Monitor "Virtual-1"
#        SubSection "Display"
#        EndSubSection
#EndSection
#'';
}
