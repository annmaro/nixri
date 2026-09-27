{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "io.github.flattool.Warehouse"
      "com.logseq.Logseq"
      "io.github.giantpinkrobots.varia"
      "com.yacreader.YACReader"
    ];
    update.onActivation = true;
  };
}
