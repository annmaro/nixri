{ ... }:

{
  services = {
    libinput.enable = true;
    fstrim.enable = true;
    devmon.enable = true;
    udisks2.enable = true;
    dbus.enable = true;
    blueman.enable = true;
    tumbler.enable = true;
    gnome.gnome-keyring.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 2048;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              "pulse.min.req" = "32/44100";
              "pulse.default.req" = "512/44100";
              "pulse.max.req" = "2048/44100";
              "pulse.min.quantum" = "32/44100";
              "pulse.max.quantum" = "2048/44100";
            };
          }
        ];
      };
    };
  };
}
