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
local package_path_str = "/Users/rela/.cache/nvim/packer_hererocks/2.1.1753364724/share/lua/5.1/?.lua;/Users/rela/.cache/nvim/packer_hererocks/2.1.1753364724/share/lua/5.1/?/init.lua;/Users/rela/.cache/nvim/packer_hererocks/2.1.1753364724/lib/luarocks/rocks-5.1/?.lua;/Users/rela/.cache/nvim/packer_hererocks/2.1.1753364724/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/rela/.cache/nvim/packer_hererocks/2.1.1753364724/lib/lua/5.1/?.so"
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
  ["Nvim-R"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/Nvim-R",
    url = "https://github.com/jalvesaq/Nvim-R"
  },
  catppuccin = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["coc.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  harpoon = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/ThePrimeagen/harpoon"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  note_plugin = {
    config = { "\27LJ\2\nß\4\0\0\b\0\26\00016\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\0016\0\4\0009\0\5\0009\0\6\0006\1\0\0'\3\1\0B\1\2\2\18\2\0\0'\4\a\0'\5\b\0009\6\t\0015\a\n\0B\2\5\1\18\2\0\0'\4\a\0'\5\v\0009\6\f\0015\a\r\0B\2\5\1\18\2\0\0'\4\a\0'\5\14\0009\6\15\0015\a\16\0B\2\5\1\18\2\0\0'\4\a\0'\5\17\0009\6\18\0015\a\19\0B\2\5\1\18\2\0\0'\4\a\0'\5\20\0009\6\21\0015\a\22\0B\2\5\1\18\2\0\0'\4\a\0'\5\23\0009\6\24\0015\a\25\0B\2\5\1K\0\1\0\1\0\1\tdesc\17Notes by Tag\17notes_by_tag\15<leader>nt\1\0\1\tdesc\28Update Note (Telescope)\16update_note\15<leader>nu\1\0\1\tdesc\28Delete Note (Telescope)\16delete_note\15<leader>nd\1\0\1\tdesc\20View Note by ID\14view_note\15<leader>nv\1\0\1\tdesc\31List Notes (vim.ui.select)\15list_notes\15<leader>nl\1\0\1\tdesc\16Create Note\16create_note\15<leader>nn\6n\bset\vkeymap\bvim\1\0\2\fapi_key\17your-api-key\rbase_url http://localhost:8080/notes\nsetup\16note_plugin\frequire\0" },
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/note_plugin",
    url = "/Users/rela/.config/nvim/lua/note_plugin/"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n[\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\17hijack_netrw\1\18disable_netrw\1\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["pomodoro.nvim"] = {
    config = { "\27LJ\2\n…\1\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\4\20time_break_long\3\20\21time_break_short\3\5\14time_work\3\25\25timers_to_long_break\3\4\nsetup\rpomodoro\frequire\0" },
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/pomodoro.nvim",
    url = "https://github.com/wthollingsworth/pomodoro.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/rela/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: note_plugin
time([[Config for note_plugin]], true)
try_loadstring("\27LJ\2\nß\4\0\0\b\0\26\00016\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\0016\0\4\0009\0\5\0009\0\6\0006\1\0\0'\3\1\0B\1\2\2\18\2\0\0'\4\a\0'\5\b\0009\6\t\0015\a\n\0B\2\5\1\18\2\0\0'\4\a\0'\5\v\0009\6\f\0015\a\r\0B\2\5\1\18\2\0\0'\4\a\0'\5\14\0009\6\15\0015\a\16\0B\2\5\1\18\2\0\0'\4\a\0'\5\17\0009\6\18\0015\a\19\0B\2\5\1\18\2\0\0'\4\a\0'\5\20\0009\6\21\0015\a\22\0B\2\5\1\18\2\0\0'\4\a\0'\5\23\0009\6\24\0015\a\25\0B\2\5\1K\0\1\0\1\0\1\tdesc\17Notes by Tag\17notes_by_tag\15<leader>nt\1\0\1\tdesc\28Update Note (Telescope)\16update_note\15<leader>nu\1\0\1\tdesc\28Delete Note (Telescope)\16delete_note\15<leader>nd\1\0\1\tdesc\20View Note by ID\14view_note\15<leader>nv\1\0\1\tdesc\31List Notes (vim.ui.select)\15list_notes\15<leader>nl\1\0\1\tdesc\16Create Note\16create_note\15<leader>nn\6n\bset\vkeymap\bvim\1\0\2\fapi_key\17your-api-key\rbase_url http://localhost:8080/notes\nsetup\16note_plugin\frequire\0", "config", "note_plugin")
time([[Config for note_plugin]], false)
-- Config for: pomodoro.nvim
time([[Config for pomodoro.nvim]], true)
try_loadstring("\27LJ\2\n…\1\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\4\20time_break_long\3\20\21time_break_short\3\5\14time_work\3\25\25timers_to_long_break\3\4\nsetup\rpomodoro\frequire\0", "config", "pomodoro.nvim")
time([[Config for pomodoro.nvim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n[\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\17hijack_netrw\1\18disable_netrw\1\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)

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
