local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")

-- Load the 'repo' extension for telescope-repo.nvim safely
pcall(function()
  telescope.load_extension("repo")
end)

-- Header (ASCII Art Logo)
dashboard.section.header.val = {
    [[      Neovim!!                       ██████                                    ]],
    [[                                ████▒▒▒▒▒▒████                                ]],
    [[                              ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
    [[                            ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                            ]],
    [[                          ██▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒                              ]],
    [[                          ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▓▓▓▓                          ]],
    [[                          ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▒▒▓▓                          ]],
    [[                        ██▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒    ██                        ]],
    [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
    [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
    [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
    [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
    [[                        ██▒▒██▒▒▒▒▒▒██▒▒▒▒▒▒▒▒██▒▒▒▒██                        ]],
    [[                        ████  ██▒▒██  ██▒▒▒▒██  ██▒▒██                        ]],
    [[                        ██      ██      ████      ████                        ]],
}

-- Buttons (Menu)
dashboard.section.buttons.val = {
  dashboard.button("e", "  New File", function()
    vim.cmd("ene")
    vim.cmd("startinsert")
  end),

  dashboard.button("f", "󰈞  Find File", function()
    vim.cmd("cd $HOME")
    telescope_builtin.find_files()
  end),

  dashboard.button("g", "󰷾  Find Word", function()
    telescope_builtin.live_grep()
  end),

  dashboard.button("r", "  Recent Files", function()
    telescope_builtin.oldfiles()
  end),

  dashboard.button("d", "  Edit Dotfiles", function()
    vim.cmd("cd ~/.config/nvim")
    telescope_builtin.find_files()
  end),

  dashboard.button("P", "  Git Repos", function()
    telescope.extensions.repo.list()
  end),

  dashboard.button("s", "  Settings", function()
    vim.cmd("e $MYVIMRC")
    vim.cmd("cd %:p:h")
  end),

  dashboard.button("U", "󰚰  Clean & Sync + Reload", function()
    vim.cmd("PackerClean")
    vim.cmd("PackerSync")
    vim.cmd("source $MYVIMRC")
  end),

  dashboard.button("u", "󰂖  Reload Config", function()
    vim.cmd("source $MYVIMRC")
  end),

  dashboard.button("q", "  Quit", function()
    vim.cmd("qa")
  end),
}

-- Footer (Dynamic Info)
local function footer()
  local datetime = os.date("  %Y-%m-%d    %H:%M:%S")

  local plugin_count = 0
  if _G.packer_plugins then
    for _ in pairs(_G.packer_plugins) do
      plugin_count = plugin_count + 1
    end
  end
  local plugins = "󰂖  " .. plugin_count

  local version = vim.version()
  local nvim_version = string.format("  v%d.%d.%d", version.major, version.minor, version.patch)

  return string.format("%s  |  %s  |  %s", datetime, plugins, nvim_version)
end

dashboard.section.footer.val = footer()

-- Highlight groups (optional customization)
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"
dashboard.section.footer.opts.hl = "Type"

-- Final setup
alpha.setup(dashboard.opts)

-- Disable folding in alpha buffer
vim.cmd([[ autocmd FileType alpha setlocal nofoldenable ]])

