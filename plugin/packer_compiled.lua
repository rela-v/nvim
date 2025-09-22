-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/jvergis/.cache/nvim/packer_hererocks/2.1.1741730670/share/lua/5.1/?.lua;/Users/jvergis/.cache/nvim/packer_hererocks/2.1.1741730670/share/lua/5.1/?/init.lua;/Users/jvergis/.cache/nvim/packer_hererocks/2.1.1741730670/lib/luarocks/rocks-5.1/?.lua;/Users/jvergis/.cache/nvim/packer_hererocks/2.1.1741730670/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/jvergis/.cache/nvim/packer_hererocks/2.1.1741730670/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    config = { "\27LJ\2\n5\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\fComment\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  ["R.nvim"] = {
    config = { "\27LJ\2\n¡\1\0\0\a\0\b\0\0196\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\3\0'\4\4\0'\5\5\0004\6\0\0B\0\6\0016\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\6\0'\4\4\0'\5\a\0004\6\0\0B\0\6\1K\0\1\0\25<Plug>RSendSelection\6v\21<Plug>RDSendLine\f<Enter>\6n\24nvim_buf_set_keymap\bapi\bvim=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\16toggle_view\14r.browser\frequireã\3\1\0\4\0\23\0\0295\0\3\0005\1\1\0003\2\0\0=\2\2\1=\1\4\0005\1\5\0=\1\6\0005\1\a\0003\2\b\0=\2\t\1=\1\n\0005\1\v\0=\1\f\0006\1\r\0009\1\14\0019\1\15\1\a\1\16\0X\1\4€'\1\18\0=\1\17\0+\1\2\0=\1\19\0006\1\20\0'\3\21\0B\1\2\0029\1\22\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\6r\frequire\21objbr_auto_start\15on startup\15auto_start\ttrue\17R_AUTO_START\benv\bvim\17disable_cmds\1\5\0\0\18RClearConsole\17RCustomStart\vRSPlot\15RSaveClose\19objbr_mappings\6v\0\1\0\3\6c\nclass\6v\0\20<localleader>gg\27head({object}, n = 15)\vR_args\1\3\0\0\f--quiet\14--no-save\thook\1\0\6\vR_args\0\17disable_cmds\0\thook\0\19objbr_mappings\0\19rconsole_width\3N\21min_editor_width\3H\16on_filetype\1\0\1\16on_filetype\0\0\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/R.nvim",
    url = "https://github.com/R-nvim/R.nvim"
  },
  ["alpha-nvim"] = {
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29core.plugin_config.alpha\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/alpha-nvim",
    url = "https://github.com/goolord/alpha-nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["cmp-r"] = {
    config = { "\27LJ\2\n…\1\0\0\5\0\a\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0004\3\3\0005\4\3\0>\4\1\3=\3\5\2B\0\2\0016\0\0\0'\2\6\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\ncmp_r\fsources\1\0\1\fsources\0\1\0\1\tname\ncmp_r\nsetup\bcmp\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/cmp-r",
    url = "https://github.com/R-nvim/cmp-r"
  },
  ["coc.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  harpoon = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/ThePrimeagen/harpoon"
  },
  ["iron.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/iron.nvim",
    url = "https://github.com/Vigemus/iron.nvim"
  },
  ["lazygit.nvim"] = {
    config = { "\27LJ\2\nu\0\0\6\0\a\0\t6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\2\fnoremap\2\vsilent\2\21<cmd>LazyGit<CR>\15<leader>gg\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/lazygit.nvim",
    url = "https://github.com/kdheepak/lazygit.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  note_plugin = {
    config = { "\27LJ\2\nú\6\0\0\b\0)\0J6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0006\4\3\0009\4\4\4'\6\5\0B\4\2\2=\4\a\0036\4\3\0009\4\4\4'\6\b\0B\4\2\2=\4\t\3B\1\2\0016\1\n\0009\1\v\0019\1\f\1\18\2\1\0'\4\r\0'\5\14\0009\6\15\0005\a\16\0B\2\5\1\18\2\1\0'\4\r\0'\5\17\0009\6\18\0005\a\19\0B\2\5\1\18\2\1\0'\4\r\0'\5\20\0009\6\21\0005\a\22\0B\2\5\1\18\2\1\0'\4\r\0'\5\23\0009\6\24\0005\a\25\0B\2\5\1\18\2\1\0'\4\r\0'\5\26\0009\6\27\0005\a\28\0B\2\5\1\18\2\1\0'\4\r\0'\5\29\0009\6\30\0005\a\31\0B\2\5\1\18\2\1\0'\4\r\0'\5 \0009\6!\0005\a\"\0B\2\5\1\18\2\1\0'\4\r\0'\5#\0009\6$\0005\a%\0B\2\5\1\18\2\1\0'\4\r\0'\5&\0009\6'\0005\a(\0B\2\5\1K\0\1\0\1\0\1\tdesc\26Jump to TODO location\24go_to_todo_location\15<leader>nJ\1\0\1\tdesc\19List all TODOs\15list_todos\15<leader>nT\1\0\1\tdesc\"Create TODO from current line\16create_todo\15<leader>nC\1\0\1\tdesc\17Notes by Tag\17notes_by_tag\15<leader>nt\1\0\1\tdesc\28Update Note (Telescope)\16update_note\15<leader>nu\1\0\1\tdesc\28Delete Note (Telescope)\16delete_note\15<leader>nd\1\0\1\tdesc\20View Note by ID\14view_note\15<leader>nv\1\0\1\tdesc\31List Notes (vim.ui.select)\15list_notes\15<leader>nl\1\0\1\tdesc\16Create Note\16create_note\15<leader>nn\6n\bset\vkeymap\bvim\rbase_url\18NOTES_API_URL\fAPI_KEY\1\0\2\rbase_url\0\fAPI_KEY\0\18NOTES_API_KEY\vgetenv\aos\nsetup\16note_plugin\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/note_plugin",
    url = "/Users/jvergis/.config/nvim/lua/note_plugin/"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-dap"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-nio"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-nio",
    url = "https://github.com/nvim-neotest/nvim-nio"
  },
  ["nvim-notify"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n[\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\18disable_netrw\1\17hijack_netrw\1\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\nÔ\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\14highlight\1\0\1\venable\2\21ensure_installed\1\0\2\21ensure_installed\0\14highlight\0\1\b\0\0\rmarkdown\20markdown_inline\6r\vrnoweb\tyaml\nlatex\bcsv\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["pomodoro.nvim"] = {
    config = { "\27LJ\2\n…\1\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\4\25timers_to_long_break\3\4\20time_break_long\3\20\21time_break_short\3\5\14time_work\3\25\nsetup\rpomodoro\frequire\0" },
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/pomodoro.nvim",
    url = "https://github.com/wthollingsworth/pomodoro.nvim"
  },
  ["telescope-repo.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/telescope-repo.nvim",
    url = "https://github.com/cljoly/telescope-repo.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/jvergis/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n[\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\18disable_netrw\1\17hijack_netrw\1\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: note_plugin
time([[Config for note_plugin]], true)
try_loadstring("\27LJ\2\nú\6\0\0\b\0)\0J6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0006\4\3\0009\4\4\4'\6\5\0B\4\2\2=\4\a\0036\4\3\0009\4\4\4'\6\b\0B\4\2\2=\4\t\3B\1\2\0016\1\n\0009\1\v\0019\1\f\1\18\2\1\0'\4\r\0'\5\14\0009\6\15\0005\a\16\0B\2\5\1\18\2\1\0'\4\r\0'\5\17\0009\6\18\0005\a\19\0B\2\5\1\18\2\1\0'\4\r\0'\5\20\0009\6\21\0005\a\22\0B\2\5\1\18\2\1\0'\4\r\0'\5\23\0009\6\24\0005\a\25\0B\2\5\1\18\2\1\0'\4\r\0'\5\26\0009\6\27\0005\a\28\0B\2\5\1\18\2\1\0'\4\r\0'\5\29\0009\6\30\0005\a\31\0B\2\5\1\18\2\1\0'\4\r\0'\5 \0009\6!\0005\a\"\0B\2\5\1\18\2\1\0'\4\r\0'\5#\0009\6$\0005\a%\0B\2\5\1\18\2\1\0'\4\r\0'\5&\0009\6'\0005\a(\0B\2\5\1K\0\1\0\1\0\1\tdesc\26Jump to TODO location\24go_to_todo_location\15<leader>nJ\1\0\1\tdesc\19List all TODOs\15list_todos\15<leader>nT\1\0\1\tdesc\"Create TODO from current line\16create_todo\15<leader>nC\1\0\1\tdesc\17Notes by Tag\17notes_by_tag\15<leader>nt\1\0\1\tdesc\28Update Note (Telescope)\16update_note\15<leader>nu\1\0\1\tdesc\28Delete Note (Telescope)\16delete_note\15<leader>nd\1\0\1\tdesc\20View Note by ID\14view_note\15<leader>nv\1\0\1\tdesc\31List Notes (vim.ui.select)\15list_notes\15<leader>nl\1\0\1\tdesc\16Create Note\16create_note\15<leader>nn\6n\bset\vkeymap\bvim\rbase_url\18NOTES_API_URL\fAPI_KEY\1\0\2\rbase_url\0\fAPI_KEY\0\18NOTES_API_KEY\vgetenv\aos\nsetup\16note_plugin\frequire\0", "config", "note_plugin")
time([[Config for note_plugin]], false)
-- Config for: lazygit.nvim
time([[Config for lazygit.nvim]], true)
try_loadstring("\27LJ\2\nu\0\0\6\0\a\0\t6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\2\fnoremap\2\vsilent\2\21<cmd>LazyGit<CR>\15<leader>gg\6n\20nvim_set_keymap\bapi\bvim\0", "config", "lazygit.nvim")
time([[Config for lazygit.nvim]], false)
-- Config for: cmp-r
time([[Config for cmp-r]], true)
try_loadstring("\27LJ\2\n…\1\0\0\5\0\a\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0004\3\3\0005\4\3\0>\4\1\3=\3\5\2B\0\2\0016\0\0\0'\2\6\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\ncmp_r\fsources\1\0\1\fsources\0\1\0\1\tname\ncmp_r\nsetup\bcmp\frequire\0", "config", "cmp-r")
time([[Config for cmp-r]], false)
-- Config for: Comment.nvim
time([[Config for Comment.nvim]], true)
try_loadstring("\27LJ\2\n5\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\fComment\frequire\0", "config", "Comment.nvim")
time([[Config for Comment.nvim]], false)
-- Config for: R.nvim
time([[Config for R.nvim]], true)
try_loadstring("\27LJ\2\n¡\1\0\0\a\0\b\0\0196\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\3\0'\4\4\0'\5\5\0004\6\0\0B\0\6\0016\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\6\0'\4\4\0'\5\a\0004\6\0\0B\0\6\1K\0\1\0\25<Plug>RSendSelection\6v\21<Plug>RDSendLine\f<Enter>\6n\24nvim_buf_set_keymap\bapi\bvim=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\16toggle_view\14r.browser\frequireã\3\1\0\4\0\23\0\0295\0\3\0005\1\1\0003\2\0\0=\2\2\1=\1\4\0005\1\5\0=\1\6\0005\1\a\0003\2\b\0=\2\t\1=\1\n\0005\1\v\0=\1\f\0006\1\r\0009\1\14\0019\1\15\1\a\1\16\0X\1\4€'\1\18\0=\1\17\0+\1\2\0=\1\19\0006\1\20\0'\3\21\0B\1\2\0029\1\22\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\6r\frequire\21objbr_auto_start\15on startup\15auto_start\ttrue\17R_AUTO_START\benv\bvim\17disable_cmds\1\5\0\0\18RClearConsole\17RCustomStart\vRSPlot\15RSaveClose\19objbr_mappings\6v\0\1\0\3\6c\nclass\6v\0\20<localleader>gg\27head({object}, n = 15)\vR_args\1\3\0\0\f--quiet\14--no-save\thook\1\0\6\vR_args\0\17disable_cmds\0\thook\0\19objbr_mappings\0\19rconsole_width\3N\21min_editor_width\3H\16on_filetype\1\0\1\16on_filetype\0\0\0", "config", "R.nvim")
time([[Config for R.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\nÔ\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\14highlight\1\0\1\venable\2\21ensure_installed\1\0\2\21ensure_installed\0\14highlight\0\1\b\0\0\rmarkdown\20markdown_inline\6r\vrnoweb\tyaml\nlatex\bcsv\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: pomodoro.nvim
time([[Config for pomodoro.nvim]], true)
try_loadstring("\27LJ\2\n…\1\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\4\25timers_to_long_break\3\4\20time_break_long\3\20\21time_break_short\3\5\14time_work\3\25\nsetup\rpomodoro\frequire\0", "config", "pomodoro.nvim")
time([[Config for pomodoro.nvim]], false)
-- Config for: alpha-nvim
time([[Config for alpha-nvim]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29core.plugin_config.alpha\frequire\0", "config", "alpha-nvim")
time([[Config for alpha-nvim]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
