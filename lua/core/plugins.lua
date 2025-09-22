-- Auto-install packer if not present
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

-- Plugin setup
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
  	'numToStr/Comment.nvim',
  	config = function()
    	require("Comment").setup()
  	end
	}

  -- Theme
  use { "catppuccin/nvim", as = "catppuccin" }

  -- Essentials
  use({
    "kdheepak/lazygit.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Map <leader>g to open lazygit
      vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>LazyGit<CR>", { noremap = true, silent = true })
    end,
  })
  use 'cljoly/telescope-repo.nvim' 
  use { 'nvim-telescope/telescope.nvim', 
    requires = { {'nvim-lua/plenary.nvim'} } 
  }
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'rcarriga/nvim-notify'

  use { 'williamboman/mason.nvim' }

  -- File Tree
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        hijack_netrw = false,
        disable_netrw = false,
      })
    end
  }

  -- R Integration
  use {
    "R-nvim/R.nvim",
    config = function()
      local opts = {
        hook = {
          on_filetype = function()
            vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
            vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
          end
        },
        R_args = {"--quiet", "--no-save"},
        min_editor_width = 72,
        rconsole_width = 78,
        objbr_mappings = {
          c = 'class',
          ['<localleader>gg'] = 'head({object}, n = 15)',
          v = function()
            require('r.browser').toggle_view()
          end
        },
        disable_cmds = {
          "RClearConsole", "RCustomStart", "RSPlot", "RSaveClose"
        },
      }
      if vim.env.R_AUTO_START == "true" then
        opts.auto_start = "on startup"
        opts.objbr_auto_start = true
      end
      require("r").setup(opts)
    end,
  }

  use {
  'goolord/alpha-nvim',
  requires = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("core.plugin_config.alpha")
  end
}


  -- cmp-r
  use {
    "R-nvim/cmp-r",
    requires = {"hrsh7th/nvim-cmp"},
    config = function()
      require("cmp").setup({ sources = {{ name = "cmp_r" }}})
      require("cmp_r").setup({})
    end,
  }

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      vim.cmd(":TSUpdate")
    end,
    config = function ()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline", "r", "rnoweb", "yaml", "latex", "csv" },
        highlight = { enable = true },
      })
    end
  }

  -- Pomodoro
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

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Harpoon 2
  use {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { "nvim-lua/plenary.nvim" }
  }

  -- Coc
  use {
    'neoclide/coc.nvim',
    branch = 'release'
  }

  -- Misc plugins
  use "nvim-neotest/nvim-nio"
  use 'neovim/nvim-lspconfig'
  use 'mfussenegger/nvim-dap'
  use 'Vigemus/iron.nvim'

  -- Local note plugin
use {
  "~/.config/nvim/lua/note_plugin/",
  config = function()
    local note = require("note_plugin")

    -- You can also call the setup function directly from here if you prefer.
    note.setup({
        API_KEY = os.getenv("NOTES_API_KEY"),
        base_url = os.getenv("NOTES_API_URL")
    })

    local map = vim.keymap.set
    map("n", "<leader>nn", note.create_note, { desc = "Create Note" })
    map("n", "<leader>nl", note.list_notes, { desc = "List Notes (vim.ui.select)" })
    map("n", "<leader>nv", note.view_note, { desc = "View Note by ID" })
    map("n", "<leader>nd", note.delete_note, { desc = "Delete Note (Telescope)" })
    map("n", "<leader>nu", note.update_note, { desc = "Update Note (Telescope)" })
    map("n", "<leader>nt", note.notes_by_tag, { desc = "Notes by Tag" })
    
    -- Add the new keymaps for the TODO functions
    map("n", "<leader>nC", note.create_todo, { desc = "Create TODO from current line" })
    map("n", "<leader>nT", note.list_todos, { desc = "List all TODOs" })
    map("n", "<leader>nJ", note.go_to_todo_location, { desc = "Jump to TODO location" })
  end
}

  -- Automatically set up config after cloning packer
  if packer_bootstrap then
    require('packer').sync()
  end
end)

