require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'catppuccin-frappe',
  },
  sections = {
    lualine_a = {
      {
        'filename',
	      path = 1,  
    },
    {
      require('pomodoro').statusline }
    }
  }
}

