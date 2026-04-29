-- Bootstrap lazy.nvim: clone it on first launch if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.scrolloff = 5

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.signcolumn = "yes:2"
vim.opt.updatetime = 100

vim.diagnostic.config({ virtual_text = true })

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    config = function()
      local langs = { "lua", "vim", "vimdoc", "markdown", "markdown_inline" }
      require("nvim-treesitter").install(langs)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = langs,
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin-nvim" },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              function()
                local dir = vim.fn.expand("%:.:h")
                if dir == "" or dir == "." then return "" end
                local parts = vim.split(dir, "/", { plain = true })
                if #parts > 2 then
                  dir = table.concat({ parts[#parts - 1], parts[#parts] }, "/")
                end
                return dir .. "/"
              end,
              color = { fg = "#7f849c" },
              padding = { left = 1, right = 0 },
              separator = "",
            },
            {
              "filename",
              path = 0,
              color = { fg = "#ffffff", gui = "bold" },
              padding = { left = 0, right = 1 },
            },
          },
          lualine_c = {},
          lualine_x = { "branch", "diff", "diagnostics" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      vim.lsp.enable({ "lua_ls", "ruff" })
    end,
  },
  {
    "airblade/vim-gitgutter",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "%.venv/",
          "venv/",
          "__pycache__/",
          "%.mypy_cache/",
          "%.ruff_cache/",
          "%.pytest_cache/",
          "dist/",
          "build/",
          "target/",
          "%.next/",
          "%.DS_Store",
        },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "fd", "--type", "f", "--hidden", "--follow", "--no-ignore-vcs" },
        },
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "stevearc/oil.nvim",
    opts = {
      float = {
        max_width = 0.8,
        max_height = 0.8,
        border = "rounded",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          local always_hidden = {
            [".."] = true,
            [".git"] = true,
            ["node_modules"] = true,
            [".venv"] = true,
            ["venv"] = true,
            ["__pycache__"] = true,
            [".mypy_cache"] = true,
            [".ruff_cache"] = true,
            [".pytest_cache"] = true,
            ["dist"] = true,
            ["build"] = true,
            ["target"] = true,
            [".next"] = true,
            [".DS_Store"] = true,
          }
          return always_hidden[name] == true
        end,
      },
    },
  },
})

vim.keymap.set("n", "-", "<cmd>Oil --float<cr>", { desc = "Open parent directory" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
  end,
})

-- If nvim is launched on a directory (e.g. `nvim .`), reopen oil as a float
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.bo.filetype ~= "oil" then return end
    local oil = require("oil")
    local dir = oil.get_current_dir()
    vim.cmd("bdelete")
    oil.open_float(dir)
  end,
})
