{ ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  programs.ssh.extraConfig = ''
    Host github.com
      Hostname ssh.github.com
      Port 443
      User git
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];
  services.gvfs.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    browseDomains = [ ];
  };
}
