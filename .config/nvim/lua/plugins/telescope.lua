return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.0",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    defaults = {
      file_ignore_patterns = {
        -- Hide directories
        "^%.git/",
        "^%.venv/",
        "^node_modules/",
        "^%.cache/",
        "^%.local/",
      },
      -- Show hidden files
      hidden = true,
      no_ignore = false, -- Don't ignore files from .gitignore, but still respect file_ignore_patterns
    },
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = false,
      },
    },
  },
}
