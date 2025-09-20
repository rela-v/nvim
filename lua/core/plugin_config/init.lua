vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")
require("core.plugin_config.lualine")
require("core.plugin_config.catppuccin")
require("core.plugin_config.nvim-tree")
require("core.plugin_config.treesitter")
require("core.plugin_config.telescope")
require("core.plugin_config.ultisnips")
require("core.plugin_config.harpoon")
require("core.plugin_config.commentnvim")
require("core.plugin_config.alpha")
vim.env.PATH = vim.env.PATH .. ':/opt/homebrew/bin'


