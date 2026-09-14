{ self, host, pkgs, config, ... }:
let
  inherit (import "${self}/hosts/${host}/variables.nix") gitUsername gitEmail;
in
{
      
      home.packages = [ 
        pkgs.gnupg 
        pkgs.skim   
        pkgs.peco   
      ];

      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-gnome3; 
        defaultCacheTtl = 3600; 
      };

      programs.git = {
        enable = true;

        lfs = {
          enable = true;
          skipSmudge = true; 
        };

        signing = {
          key = config.sops.secrets.git_key_id.path; 
          signByDefault = true;
        };

        ignores = [
          "*.o" "*.out" "*.result" "result" ".env" "*.env" ".DS_Store" "Thumbs.db" "*~" "*.swp"       
        ];

        # --- UNIFIED CONFIGURATION: All parameters routed through settings ---
        settings = {
          # Moved here: Maps directly to the global [user] block inside .gitconfig
          user.name = "${gitUsername}";
          user.email = "${gitEmail}";

          # Maps directly to the global [alias] block inside .gitconfig
          alias = {
            essa = "push --force";
            co = "checkout";
            fuck = "commit --amend -m";
            c = "commit -m";
            ca = "commit -am";
            forgor = "commit --amend --no-edit";
            graph = "log --all --decorate --graph --oneline";
            oops = "checkout --";
            l = "log";
            r = "rebase";
            s = "status --short";
            ss = "status";
            d = "diff";
            st = "status";
            br = "branch";
            ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
            pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
            af = "!git add $(git ls-files -m -o --exclude-standard | sk -m)";
            df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
            hist = ''
              log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
            llog = ''
              log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
            edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; hx `f`";
          };

          gpg = {
            program = "${pkgs.gnupg}/bin/gpg";
          };
          commit = {
            gpgsign = true;
          };
          init = {
            defaultBranch = "main";
          };
          push = {
            autoSetupRemote = true;
          };
          lfs = {
            pruneoffset = "30";
          };
        };
      };
}
