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
    list-gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    dots = "cd /home/annmaro/nixri";
    age = "agenix -i ~/.config/agenix/keys.txt";
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
      set -gx FZF_DEFAULT_OPTS "--color=bg+:#${config.lib.stylix.colors.base02},bg:#${config.lib.stylix.colors.base00},spinner:#${config.lib.stylix.colors.base0A},hl:#${config.lib.stylix.colors.base08} --color=fg:#${config.lib.stylix.colors.base05},header:#${config.lib.stylix.colors.base0D},info:#${config.lib.stylix.colors.base0E},pointer:#${config.lib.stylix.colors.base0A}"
      set -g fish_color_autosuggestion green
    '';

    functions = {
      dmount = ''
              set -l selection (lsblk -rpo "NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT" | \
                  awk '$3=="part" && $4!="swap" && $6=="" {print $1, "(" $2, $4, ($5 ? $5 : "no-label") ")"}' | \
                  fzf --header="Select partition to mount" --prompt="Mount > " --height=40% --reverse)

              if test -z "$selection"
                  echo "No partition selected."
                  return 0
              end

              set -l target_device (string split ' ' -- $selection)[1]
              echo "Mounting $target_device..."

              # Run udisksctl, capturing stdout and stderr
              set -l out (udisksctl mount -b "$target_device" 2>&1)
              set -l status_code $status

              echo $out

              if test $status_code -eq 0
                  # Extract path and strip trailing dot added by udisksctl
                  set -l mount_path (string replace -r '.* at (.*?)\.?$' '$1' -- $out)

                  notify-send -u normal -i drive-harddisk "Drive Mounted" "$target_device\n→ $mount_path"

                  if test -d "$mount_path"
                      cd "$mount_path"
                      echo "Opening superfile in: $mount_path"
                      spf "$mount_path"
                  end
              else
                  notify-send -u critical -i dialog-error "Mount Failed" "$out"
              end
            '';
      dumount = ''
        set -l selection (lsblk -rpo "NAME,SIZE,TYPE,MOUNTPOINT,LABEL" | \
            awk '$3=="part" && $4!="" && $4!="/" && $4!="/boot" && $4!="/nix/store" {print $1, "(" $2, $4, ($5 ? $5 : "") ")"}' | \
            fzf --header="Select partition to unmount" --prompt="Unmount > " --height=40% --reverse)

        if test -z "$selection"
            echo "No partition selected."
            return 0
        end

        set -l target_device (string split ' ' -- $selection)[1]
        echo "Unmounting $target_device..."
        udisksctl unmount -b "$target_device"
      '';
    };

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
