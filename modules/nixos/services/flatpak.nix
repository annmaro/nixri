{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "io.github.flattool.Warehouse"
      "app.opencomic.OpenComic"
      "org.sabnzbd.sabnzbd"
      "org.freefilesync.FreeFileSync"
      "io.github.giantpinkrobots.varia"
      "com.bilingify.readest"
    ];
    update.onActivation = true;
  };
}
