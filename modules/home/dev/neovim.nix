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
                model = "gemini-3.1-pro-preview";
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

      # CLI tools and LSP servers exposed to Neovim's PATH
      extraPackages = with pkgs; [
        nixd
        nixfmt
        rust-analyzer
        rustfmt
        clippy
        pyright
        ruff
      ];

      # Vim plugins loaded into Neovim's runtimepath
      extraPlugins = with pkgs.vimPlugins; {
        mini-nvim.package = mini-nvim;
        snacks-nvim.package = snacks-nvim;
        trouble-nvim.package = trouble-nvim;
        lspsaga-nvim.package = lspsaga-nvim;
        lspkind-nvim.package = lspkind-nvim;
        lsp-signature-nvim.package = lsp_signature-nvim;
      };

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
          map("n", "<leader>f", "<cmd>lua require('conform').format({ async = true, lsp_format = 'fallback' })<CR>", opts)
          map("n", "<leader>t", "<cmd>lua Snacks.terminal.toggle()<CR>", opts)
          map("n", "<leader>tf", "<cmd>lua Snacks.terminal.toggle(nil, { style = 'float' })<CR>", opts)
          map("n", "<leader>tg", "<cmd>lua Snacks.lazygit()<CR>", opts)
          map("n", "<leader>uw", "<cmd>set wrap!<CR>", opts)
          map("n", "<leader>ul", "<cmd>set linebreak!<CR>", opts)
          map("n", "<leader>us", "<cmd>set spell!<CR>", opts)
          map("n", "<leader>uc", "<cmd>set cursorline!<CR>", opts)
          map("n", "<leader>un", "<cmd>set number!<CR>", opts)
          map("n", "<leader>ur", "<cmd>set relativenumber!<CR>", opts)
          map("n", "<leader>ut", "<cmd>set showtabline=2<CR>", opts)
          map("n", "<leader>uT", "<cmd>set showtabline=0<CR>", opts)
          map("n", "<leader>xt", "<cmd>TodoTrouble<CR>", opts)

          -- Normal mode: Run shell command and paste stdout
          map("n", "<leader>!", function()
            local cmd = vim.fn.input('Command: ')
            if cmd == "" then return end
            local lines = vim.fn.systemlist(cmd)
            vim.api.nvim_put(lines, "l", true, true)
          end, opts)

          -- Visual mode: Filter selected range through shell command
          map("v", "<leader>!", function()
            local start_line = vim.fn.line("'<")
            local end_line = vim.fn.line("'>")
            local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
            local input_text = table.concat(lines, "\n")
            local cmd = vim.fn.input('$ ')
            if cmd == "" then return end
            local result = vim.fn.system({ "bash", "-c", cmd }, input_text)
            local output = vim.split(result, "\n", { plain = true })
            if output[#output] == "" then table.remove(output) end
            if #output == 0 then return end
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, output)
          end, opts)

          map("v", ">", ">gv", opts)
          map("v", "<", "<gv", opts)
          map({ "n", "v" }, "<C-d>", "<C-d>zz", opts)
          map({ "n", "v" }, "<C-u>", "<C-u>zz", opts)
          map("n", "<C-s>", "<cmd>w<CR>", opts)
          map("n", "<Esc>", "<Nop>", opts)
          map("n", "<Up>", "<Nop>", opts)
          map("n", "<Down>", "<Nop>", opts)
          map("n", "<Left>", "<Nop>", opts)
          map("n", "<Right>", "<Nop>", opts)
        '';

        extraLuaConfig = ''
          require('snacks').setup({
            quickfile = { enabled = true },
            statuscolumn = { enabled = true },
            zen = { enabled = true },
            bufdelete = { enabled = true },
            gitsigns = { enabled = true },
            animate = { enabled = true },
            lazygit = { enabled = true, configure = false },
            terminal = { enabled = true },
          })
        '';
      };
    };
  };
}
