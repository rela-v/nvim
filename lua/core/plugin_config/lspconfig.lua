-- lua/config/lsp.lua
local lspconfig = require('lspconfig')

-- R Language Server configuration
lspconfig.rls.setup {
    -- This 'cmd' specifies how to start the R Language Server.
    -- It tells R to run in slave mode and execute languageserver::run().
    cmd = { 'R', '--slave', '-e', 'languageserver::run()' },
    -- 'filetypes' tells nvim-lspconfig for which file types this server should be activated.
    filetypes = { 'r', 'rmd', 'quarto' },
    -- root_dir helps the LSP server understand the project context (e.g., for .Rproj files).
    root_dir = lspconfig.util.root_pattern('.Rproj', '.git', 'DESCRIPTION'),
    -- on_attach is a function that runs after the LSP server attaches to a buffer.
    -- This is a good place to set up keybindings for LSP features.
    on_attach = function(client, bufnr)
        -- Enable completion
        -- (If you're using nvim-cmp, this part will be handled by its setup)
        -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Example keybindings for common LSP features
        local buf_set_option = vim.api.nvim_buf_set_option
        local buf_set_keymap = vim.api.nvim_buf_set_keymap
        local opts = { noremap=true, silent=true }

        -- Basic LSP keymaps (customize as needed)
        buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts) -- show diagnostics in floating window
        buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)

        -- Set up completion capabilities specific to your completion plugin (e.g., nvim-cmp)
        -- if client.server_capabilities.completionProvider then
        --     require('cmp').setup.buffer({
        --         sources = {{name = 'nvim_lsp'}},
        --     })
        -- end
    end,
}
