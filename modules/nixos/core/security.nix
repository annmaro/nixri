{ pkgs, ... }:

{
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.sddm.enableGnomeKeyring = true;
    sudo.extraConfig = "Defaults pwfeedback";

    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [ pkgs.apparmor-profiles ];
    };
  };
}
