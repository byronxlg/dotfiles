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

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.scrolloff = 5

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
    build = ":TSUpdate",
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
          return name == ".." or name == ".git"
        end,
      },
    },
  },
})

vim.keymap.set("n", "-", "<cmd>Oil --float<cr>", { desc = "Open parent directory" })

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
