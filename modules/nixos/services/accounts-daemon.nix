{ config, ... }:

let
  profileIcon = ../../../assets/nix.png;
  username = config.systemSettings.username;
in
{
  services.accounts-daemon.enable = true;

  systemd.tmpfiles.rules = [
    "f+ /var/lib/AccountsService/users/${username} 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n"
    "L+ /var/lib/AccountsService/icons/${username} - - - - ${profileIcon}"
  ];
}
