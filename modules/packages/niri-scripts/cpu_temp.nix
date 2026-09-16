{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "cpu_temp";

  runtimeInputs = with pkgs; [
    coreutils
    lm_sensors     # provides sensors
    gnugrep        # provides grep
    gawk           # provides awk
  ];

  text = ''
    sensors -C | grep 'CPU:' | awk '{print \$2}'
  '';
}