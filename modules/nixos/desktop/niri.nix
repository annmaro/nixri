{
  ...
}:

{
  # Both profiles are imported unconditionally so module discovery does not
  # depend on the value of another module option. Each profile gates its own
  # configuration with systemSettings.bar.
  imports = [
    ../_niri/dms_niri.nix
    ../_niri/noctalia_niri.nix
  ];
}
