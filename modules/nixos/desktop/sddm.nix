{ inputs, pkgs, ... }:

let
  sddm-theme = inputs.silentSDDM.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    theme = "silvia";
  };
in
{
  environment.systemPackages = [
    sddm-theme
    sddm-theme.test
  ];

  qt.enable = true;
  services.accounts-daemon.enable = true;
  services.displayManager = {
    generic.preStart = ''
      echo "Sleeping to wait for session registration..."
      sleep 1
    '';
    defaultSession = "niri";
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = sddm-theme.pname;
      extraPackages = sddm-theme.propagatedBuildInputs;
      settings.General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };
}
