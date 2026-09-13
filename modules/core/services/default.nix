{ ... }:
{
  # Services to start
  services = {
    libinput.enable = true; # Input Handling
    fstrim.enable = true; # SSD Optimizer
    devmon.enable = true; # For Mounting USB & More
    udisks2.enable = true; # For Mounting USB & More
    dbus.enable = true; # interprocess communications manager

    # Userspace CPU Scheduler for Improved Latency for Gaming (Hardware Specific)
    # services.scx = {
    #   enable = true;
    #   package = pkgs.scx.rustscheds;
    #   scheduler = "scx_lavd"; # https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
    # };

    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    gnome.gnome-keyring.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      # wireplumber = {
      #   enable = true;
      #   configPackages = [
      #     (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
      #       bluetooth.autoswitch-to-headset-profile = false
      #     '')
      #   ];
      # };
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          # 1. Base clock matches CD quality (avoiding resampling normal audio)
          "default.clock.rate" = 44100;

          # 2. Complete Hi-Res ranges matching standard album rates
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            176400
            192000
            352800
            384000
          ];

          # 3. Dynamic quantum window for both speed and stability
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
              # 4. Allows the Gapless app to request larger buffer sizes on the fly
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
