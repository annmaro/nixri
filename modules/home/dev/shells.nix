{ config, lib, pkgs, ... }:

let
  isFish = config.homeSettings.shell == "fish";
  isBash = config.homeSettings.shell == "bash";
  isZsh = config.homeSettings.shell == "zsh";
  commonAliases = {
    cls = "clear";
    l = "eza -lh --icons=auto";
    ls = "eza -1 --icons=auto";
    ll = "eza -lha --icons=auto --sort=name --group-directories-first";
    tree = "eza --icons=auto --tree";
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -vI";
    mkd = "mkdir -pv";
    grep = "grep --color=always";
    nf = "${pkgs.microfetch}/bin/microfetch";
    tp = "${pkgs.trash-cli}/bin/trash-put";
    tpr = "${pkgs.trash-cli}/bin/trash-restore";
    nfu = "nix flake update";
    nfs = "nix flake show";
    nrs = "sudo nixos-rebuild switch --flake .#laptop";
    dr = "nixos-rebuild dry-run --flake .#laptop";
    ncb = "sudo nix-collect-garbage -d";
    nhb = "nh os boot --hostname laptop";
    nhu = "nh os switch --hostname laptop";
    dots = "cd /home/annmaro/nixri";
  };
in
{
  home.packages = with pkgs; [
    eza
    fd
    fzf
    lf
    trash-cli
  ];

  programs.fish = lib.mkIf isFish {
    enable = true;
    interactiveShellInit = ''
      bind \ca beginning-of-line
      bind \ce end-of-line
      set -gx FZF_DEFAULT_OPTS "--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6"
      set -g fish_color_autosuggestion green
    '';
    shellAbbrs = commonAliases;
  };

  programs.bash = lib.mkIf isBash {
    enable = true;
    enableCompletion = true;
    historyFileSize = 100000;
    shellOptions = [ "autocd" "cdspell" "cmdhist" "dotglob" "histappend" "expand_aliases" "checkwinsize" ];
    shellAliases = commonAliases;
    initExtra = ''
      eval "$(direnv hook bash)"
    '';
  };

  programs.zsh = lib.mkIf isZsh {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 100000;
    shellAliases = commonAliases;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
  };
}
