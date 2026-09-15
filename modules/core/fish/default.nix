{ self, pkgs, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
        };

        programs.fish = {
          enable = true;

          interactiveShellInit = ''
            # Key Bindings
            bind \ca beginning-of-line
            bind \ce end-of-line

            # Environment variables
            set -q XDG_CONFIG_HOME; and set -gx XMONAD_CONFIG_DIR "$XDG_CONFIG_HOME/xmonad"; or set -gx XMONAD_CONFIG_DIR "$HOME/.config/xmonad"
            set -q XDG_DATA_HOME; and set -gx XMONAD_DATA_DIR "$XDG_DATA_HOME/xmonad"; or set -gx XMONAD_DATA_DIR "$HOME/.local/share/xmonad"
            set -q XDG_CACHE_HOME; and set -gx XMONAD_CACHE_DIR "$XDG_CACHE_HOME/xmonad"; or set -gx XMONAD_CACHE_DIR "$HOME/.cache/xmonad"
            set -gx FZF_DEFAULT_OPTS " --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"

            # Override autosuggestion color to green
            set -g fish_color_autosuggestion green

            # Make parameters use normal text color instead of dim grey from base16
            set -g fish_color_param normal
          '';

          functions = {
            UUID = "uuidgen | tr -d \\n";
            lf = ''
              set tmp (mktemp)
              command lf -last-dir-path=$tmp $argv
              if test -f "$tmp"
                  set dir (cat "$tmp")
                  rm -f "$tmp"
                  if test -d "$dir"
                      if test "$dir" != (pwd)
                          cd "$dir"
                      end
                  end
              end
            '';
            fnew = ''
              if test -d "$argv[2]"
                echo "Directory \"$argv[2]\" already exists!"
                return 1
              end
              nix flake new $argv[2] --template ${self}/dev-shells#$argv[1]
              cd $argv[2]
              direnv allow
            '';
            finit = ''
              nix flake init --template ${self}/dev-shells#$argv[1]
              direnv allow
            '';
            cdown = ''
              set N $argv[1]
              while test $N -gt 0
                echo "$N" | figlet -c | lolcat; and sleep 1
                set N (math $N - 1)
              end
            '';
            find-store-path = ''
              nix-shell -p $argv[1] --command "nix eval -f \"<nixpkgs>\" --raw $argv[1]"
            '';
          };

          shellAbbrs = {
            G = "| grep";
            cls = "clear";
            tml = "tmux list-sessions";
            tma = "tmux attach";
            tms = "tmux attach -t (tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' | fzf | cut -d: -f1)";
            l = "eza -lh  --icons=auto";
            ls = "eza -1   --icons=auto";
            ll = "eza -lha --icons=auto --sort=name --group-directories-first";
            ld = "eza -lhD --icons=auto";
            tree = "eza --icons=auto --tree";
            vc = "code --disable-gpu";
            nv = "nvim";
            nf = "${pkgs.microfetch}/bin/microfetch";
            cp = "cp -iv";
            mv = "mv -iv";
            rm = "rm -vI";
            bc = "bc -ql";
            mkd = "mkdir -pv";
            tp = "${pkgs.trash-cli}/bin/trash-put";
            tpr = "${pkgs.trash-cli}/bin/trash-restore";
            grep = "grep --color=always";
            pokemon = "pokego --random 1-8 --no-title";

            list-gens = "nixos-rebuild list-generations";
            nfu = "nix flake update";
            nfs = "nix flake show";
            wp = "hyprctl hyprpaper reload ,";
            nrs = "sudo nixos-rebuild boot --flake .#default";
            nhu = "nh os switch --hostname default";
            nrb = "nh os boot --hostname default";
            da = "sudo nixos-rebuild dry-activate --flake .#default";
            dr = "nixos-rebuild dry-run --flake .#default";
            ncb = "sudo nix-collect-garbage -d";
            ncg = "sudo nix-collect-garbage -d; and sudo /run/current-system/bin/switch-to-configuration boot";
            agenix = "agenix -i ~/.config/agenix/key.txt";

            dots = "cd ~/nixri/";
            games = "cd /mnt/games/";
            work = "cd /mnt/work/";
            media = "cd /mnt/work/media/";
            projects = "cd /mnt/work/Projects/";
            proj = "cd /mnt/work/Projects/";
            dev = "cd /mnt/work/Projects/";
          };
        };
      }
    )
  ];
}
