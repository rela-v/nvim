local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use { "catppuccin/nvim", as = "catppuccin" }
use {
  'nvim-tree/nvim-tree.lua',
  requires = {
    'nvim-tree/nvim-web-devicons', -- optional, but recommended
  },
  config = function()
    require('nvim-tree').setup({
      -- Add these two lines to your existing setup
      hijack_netrw = false,
      disable_netrw = false,
      -- ... other settings ...
    })
  end
}
  use 'nvim-tree/nvim-web-devicons'
  use 'nvim-lualine/lualine.nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use {
    'williamboman/mason.nvim',
  }
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    requires = { { 'nvim-lua/plenary.nvim'} }
  }
  use 'jalvesaq/Nvim-R'
  use "nvim-lua/plenary.nvim" -- don't forget to add this one if you don't have it yet!
  use {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { {"nvim-lua/plenary.nvim"} }
  }
  use {
    'wthollingsworth/pomodoro.nvim',
    requires = 'MunifTanjim/nui.nvim',
    config = function()
        require('pomodoro').setup({
            time_work = 25,
            time_break_short = 5,
            time_break_long = 20,
            timers_to_long_break = 4
        })
    end
  }
  use { 'neoclide/coc.nvim', branch = 'release' }
  use {
  "~/.config/nvim/lua/note_plugin/",
  config = function()
    require("note_plugin").setup({
      api_key = "your-api-key",
      base_url = "http://localhost:8080/notes"
    })

    -- Safe keybindings with a unique namespace (nn = note plugin)
    local map = vim.keymap.set
    local note = require("note_plugin")

    -- Create a new note buffer
map("n", "<leader>nn", note.create_note, { desc = "Create Note" })

-- List and view notes using vim.ui.select
map("n", "<leader>nl", note.list_notes, { desc = "List Notes (vim.ui.select)" })

-- View a specific note by ID (prompts for ID)
map("n", "<leader>nv", note.view_note, { desc = "View Note by ID" })

-- Delete a note using a Telescope picker
map("n", "<leader>nd", note.delete_note, { desc = "Delete Note (Telescope)" })

-- Update an existing note using a Telescope picker
map("n", "<leader>nu", note.update_note, { desc = "Update Note (Telescope)" })

-- Find notes by tag (prompts for tag)
map("n", "<leader>nt", note.notes_by_tag, { desc = "Notes by Tag" })
  end
}
  -- My plugins here
  -- use 'foo1/bar1.nvim'
  -- use 'foo2/bar2.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
