{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = config.homeSettings.editor == "neovim";

    settings.vim = {
      viAlias = true;
      vimAlias = true;
      lineNumberMode = "relNumber";
      syntaxHighlighting = true;
      options = {
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        signcolumn = "yes";
        updatetime = 250;
        completeopt = "menu,menuone,noselect";
      };

      theme = {
        enable = true;
        name = lib.mkForce "gruvbox";
        style = "dark";
      };

      treesitter.enable = true;
      autocomplete.nvim-cmp.enable = true;

      lsp.enable = true;
      languages = {
        nix = {
          enable = true;
          lsp.enable = true;
          lsp.servers = [ "nixd" ];
          format.enable = true;
          format.type = [ "nixfmt" ];
        };
        rust = {
          enable = true;
          lsp.enable = true;
          lsp.servers = [ "rust-analyzer" ];
          format.enable = true;
          format.type = [ "rustfmt" ];
        };
        python = {
          enable = true;
          lsp.enable = true;
          lsp.servers = [ "pyright" ];
          format.enable = false;
        };
      };

      assistant = {
        avante-nvim = {
          enable = true;
          setupOpts = {
            provider = "gemini";
            auto_suggestions_provider = "gemini";
            providers = {
              gemini = {
                __inherited_from = "openai";
                endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/";
                model = "gemini-2.5-flash";
                api_key_name = "GEMINI_API_KEY";
                timeout = 30000;
              };
              copilot = {
                model = "gpt-4o";
              };
            };
          };
        };

        # Copilot stays installed and available as an alternative Avante provider.
        copilot.enable = true;
      };

      extraPackages = with pkgs; [
        nixd
        nixfmt
        rust-analyzer
        rustfmt
        clippy
        pyright
        ruff
      ];

      luaConfigRC = {
        editor = ''
          vim.g.mapleader = " "
          vim.g.maplocalleader = " "
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.cursorline = true
          vim.opt.termguicolors = true
          vim.opt.splitright = true
          vim.opt.splitbelow = true
          vim.opt.ignorecase = true
          vim.opt.smartcase = true
        '';

        keymaps = ''
          local map = vim.keymap.set
          local opts = { noremap = true, silent = true }

          map("n", "<leader>ag", function()
            require("avante").setup({ provider = "gemini" })
            vim.notify("Avante provider: Gemini")
          end, opts)
          map("n", "<leader>ac", function()
            require("avante").setup({ provider = "copilot" })
            vim.notify("Avante provider: Copilot")
          end, opts)
          map({ "n", "v" }, "<leader>aa", "<cmd>AvanteAsk<CR>", opts)
          map("n", "<leader>af", "<cmd>AvanteFocus<CR>", opts)
          map("n", "<leader>e", vim.diagnostic.open_float, opts)
          map("n", "[d", vim.diagnostic.goto_prev, opts)
          map("n", "]d", vim.diagnostic.goto_next, opts)
          map("n", "<leader>w", "<cmd>w<CR>", opts)
          map("n", "<leader>q", "<cmd>q<CR>", opts)
          map("n", "<C-h>", "<C-w>h", opts)
          map("n", "<C-j>", "<C-w>j", opts)
          map("n", "<C-k>", "<C-w>k", opts)
          map("n", "<C-l>", "<C-w>l", opts)
        '';
      };
    };
  };
}
