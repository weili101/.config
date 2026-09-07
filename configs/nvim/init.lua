-- ~/.config/nvim/init.lua
-- Minimal VS Code-like Neovim config:
-- Python LSP, LaTeX/VimTeX, file tree, outline, bottom terminal, git, fuzzy find.
-- Leader = space.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- Core options
-- ============================================================
local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.signcolumn = "yes"

opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.wrap = true          -- Enable line wrapping
opt.linebreak = true     -- Wrap lines at convenient words
opt.breakindent = true   -- Match indentation of the wrapped line

opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.confirm = true

opt.completeopt = { "menu", "menuone", "noselect" }

-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({
  -- ------------------------------------------------------------
  -- Theme
{
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    require("catppuccin").setup({
      flavour = "Latte",
      integrations = {
        cmp = true,
        gitsigns = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        neotree = true,
        aerial = true,
        lualine = true,
      },
    })

    vim.cmd.colorscheme("catppuccin")
  end,
},

{
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "catppuccin/nvim",
  },
  opts = function()
    return {
      options = {
        theme = "auto",
        globalstatus = true,
      },
    }
  end,
},
  -- which-key
  -- ------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ------------------------------------------------------------
-- ------------------------------------------------------------
-- Treesitter for Neovim 0.12+
-- New nvim-treesitter main API.
-- LaTeX is intentionally excluded; let VimTeX handle .tex files.
-- ------------------------------------------------------------
{
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    ts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    local parsers = {
      "python",
      "markdown",
      "markdown_inline",
      "lua",
      "vim",
      "vimdoc",
      "yaml",
      "json",
      "toml",
      "bash",
    }

    ts.install(parsers)

    -- Enable Treesitter highlighting for selected filetypes.
    -- Do NOT include tex/latex here; VimTeX handles LaTeX better.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "python",
        "markdown",
        "lua",
        "vim",
        "yaml",
        "json",
        "toml",
        "bash",
        "sh",
      },
      callback = function()
        pcall(vim.treesitter.start)

        -- Optional Treesitter indentation.
        pcall(function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })
  end,
},
  -- ------------------------------------------------------------
  -- Telescope: fuzzy finder
  -- ------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
    opts = {},
  },

  -- ------------------------------------------------------------
  -- Neo-tree: VS Code-like file explorer
  -- ------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>ee", "<cmd>Neotree toggle left filesystem reveal<cr>", desc = "File tree" },
      { "<leader>ef", "<cmd>Neotree focus filesystem left<cr>", desc = "Focus file tree" },
      { "<leader>eb", "<cmd>Neotree toggle left buffers<cr>", desc = "Buffer tree" },
      { "<leader>eg", "<cmd>Neotree toggle left git_status<cr>", desc = "Git tree" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,

      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },

      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },

  -- ------------------------------------------------------------
  -- Aerial: right-side symbol outline
  -- ------------------------------------------------------------
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>oo", "<cmd>AerialToggle right<cr>", desc = "Toggle outline" },
      { "<leader>of", "<cmd>AerialFocus<cr>", desc = "Focus outline" },
    },
    opts = {
      layout = {
        default_direction = "right",
        width = 32,
      },
      attach_mode = "window",
      show_guides = true,
    },
  },

  -- ------------------------------------------------------------
  -- Gitsigns: git changes in gutter
  -- ------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ------------------------------------------------------------
  -- Comment toggling
  -- ------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    keys = { "gc", "gcc", "gbc" },
    opts = {},
  },

  -- ------------------------------------------------------------
  -- ToggleTerm: VS Code-like bottom terminal
  -- ------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
  -- Bottom terminal, like VS Code integrated terminal
  {
    "<leader>tt",
    "<cmd>ToggleTerm 1 direction=horizontal<cr>",
    desc = "Bottom terminal",
  },

  -- Right-side terminal
  {
    "<leader>tv",
    "<cmd>ToggleTerm 2 direction=vertical size=50<cr>",
    desc = "Side terminal",
  },

  -- Floating terminal
  {
    "<leader>tf",
    "<cmd>ToggleTerm 3 direction=float<cr>",
    desc = "Floating terminal",
  },

  -- Lazygit floating terminal
  {
    "<leader>gg",
    function()
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },
      })
      lazygit:toggle()
    end,
    desc = "Lazygit",
  },
},
    config = function()
      require("toggleterm").setup({
        size = 14,
        direction = "horizontal",
        shade_terminals = true,
        persist_size = true,
        start_in_insert = true,
        close_on_exit = true,
      })

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
          local opts = { buffer = true, silent = true }

          vim.keymap.set("t", "<ij>", [[<C-\><C-n>]], opts)
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
        end,
      })
    end,
  },

  -- ------------------------------------------------------------
  -- Trouble: VS Code-like Problems panel
  -- ------------------------------------------------------------
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
    },
    opts = {},
  },

  -- ------------------------------------------------------------
  -- LSP: Pyright + Ruff
  -- ------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("pyright", {
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            lineLength = 88,
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff" },
        automatic_enable = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
              buffer = event.buf,
              silent = true,
              desc = desc,
            })
          end

          map("n", "<leader>ld", vim.lsp.buf.definition, "Go to definition")
          map("n", "<leader>lr", vim.lsp.buf.references, "References")
          map("n", "<leader>lh", vim.lsp.buf.hover, "Hover docs")
          map("n", "<leader>lc", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>ln", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format buffer")

          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "<leader>le", vim.diagnostic.open_float, "Line diagnostic")
        end,
      })
    end,
  },

  -- ------------------------------------------------------------
  -- Completion
  -- ------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Safer than select=true: Enter only confirms an explicitly selected item.
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        },
      })
    end,
  },


  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 
      'nvim-treesitter/nvim-treesitter', -- Required for parsing
      'echasnovski/mini.icons'           -- Optional: for beautiful heading/file icons
    },
    ft = { 'markdown', 'codecompanion' }, -- Lazy-load on markdown files
    opts = {
      heading = {
        sign = false,
        icons = { '   ', '   ', '   ', '   ', '   ', '   ' },
      },
      checkbox = {
        enabled = true,
      },
    },
},

  -- ------------------------------------------------------------
  -- LaTeX: VimTeX
  -- ------------------------------------------------------------
{
  "lervag/vimtex",
  ft = { "tex", "plaintex", "bib" },
  init = function()
    vim.g.tex_flavor = "latex"
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_compiler_method = "latexmk"
  end,
},
})


-- ============================================================
-- General keymaps
-- ============================================================

-- Save / quit
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Exit terminal mode
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Avoid mapping jk in command-line mode.
vim.keymap.set({ "i", "v", "s" }, "jk", "<Esc>", { desc = "Exit to normal mode" })

-- Window navigation: VS Code-like pane movement
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Split management
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })

-- Resize windows
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Equalize windows" })
vim.keymap.set("n", "<leader>+", "<cmd>resize +3<cr>", { desc = "Increase height" })
vim.keymap.set("n", "<leader>-", "<cmd>resize -3<cr>", { desc = "Decrease height" })
vim.keymap.set("n", "<leader>>", "<cmd>vertical resize +5<cr>", { desc = "Increase width" })
vim.keymap.set("n", "<leader><", "<cmd>vertical resize -5<cr>", { desc = "Decrease width" })
