require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'catppuccin-frappe',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    ignore_focus = {},
    always_last_line = true,
  },
  sections = {
    lualine_a = {
      'mode',
      { require('pomodoro').statusline }
    },
    lualine_b = {
      'branch',
      'diff',
      'diagnostics',
    },
    lualine_c = {
      {
        'filename',
        path = 1,
        file_status = true,
        symbols = {
          modified = '●',
          readonly = '⌘',
          unnamed = '[No Name]',
          newfile = '[New]',
        }
      },
      'filetype',
      -- Replace your custom function with Lualine's built-in lsp_clients component
      -- This handles displaying active LSP client names or indicating 'No LSP'
      { 'lsp_clients' }
    },
    lualine_x = {
      'encoding',
      'fileformat',
      'numhl',
      'progress',
    },
    lualine_y = {
      'location',
    },
    lualine_z = {
      {
        function()
          return os.date("%a %b %d %H:%M")
        end,
      },
    }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        path = 1,
        file_status = true,
      }
    },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
}
