{ config, lib, pkgs, profiles, user, ... }:
let
  isWayland = config.modules.labels.display == "wayland";
in
{
  # obtained from JACK entry in the NixOS wiki
  services.pipewire = {
    # already my defaults in profile/display
    #enable = true;
    #alsa.enable = true;
    #alsa.support32Bit = true;
    #pulse.enable = true;
    jack.enable = true;
  };
  users.extraUsers.${user}.extraGroups = [ "jackaudio" ];
  #security.sudo.extraConfig = ''
  #  ${user}  ALL=(ALL) NOPASSWD: ${pkgs.systemd}/bin/systemctl
  #  '';
  musnix = {
    enable = true;
    alsaSeq.enable = false;
    # Find this value with `lspci | grep -i audio` (per the musnix readme).
    # PITFALL: This is the id of the built-in soundcard.
    #   When I start using the external one, change it.
    soundcardPciId = "00:1f.3";
    # magic to me
    rtirq = {
      # highList = "snd_hrtimer";
      resetAll = 1;
      prioLow = 0;
      enable = true;
      nameList = "rtc0 snd";
    };
  };

  environment.systemPackages = with pkgs; [
    libjack2 jack2 qjackctl jack_capture
  ];
}
