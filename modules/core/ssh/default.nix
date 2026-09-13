{ ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  # Configure SSH client to use port 443 for GitHub to bypass firewall restrictions
  programs.ssh.extraConfig = ''
    Host github.com
      Hostname ssh.github.com
      Port 443
      User git
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];

  services.gvfs.enable = true; # For Mounting USB & More

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # Allows browsing services advertised on the local network
    browseDomains = [ ];
  };
}
