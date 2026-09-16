{ ... }:

{
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  systemd.oomd = {
    enable = true;
    enableUserSlices = true;
  };

  systemd.slices."user".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "90%";
  };
}
