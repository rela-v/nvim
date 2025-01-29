require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "rust", "python", "r", "javascript", "typescript", "html", "css", "nu" },

  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
  dependencies = {
        -- Install official queries and filetype detection
        -- alternatively, see section "Install official queries only"
        { "nushell/tree-sitter-nu" },
    },
}
