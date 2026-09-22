{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "io.github.flattool.Warehouse"
      "app.opencomic.OpenComic"
      "com.logseq.Logseq"
      "io.github.giantpinkrobots.varia"
<<<<<<< HEAD
=======
      "com.bilingify.readest"
>>>>>>> fix-nixos-experiment
      "net.waterfox.waterfox"
    ];
    update.onActivation = true;
  };
}
