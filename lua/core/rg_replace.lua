local M = {}

--- Replaces a given term with another term in all files found by ripgrep in a directory.
--- This function now explicitly iterates through files and prompts for confirmation
--- before saving changes to each file.
---
--- @param old_term string The term to find and replace.
--- @param new_term string The term to replace with.
--- @param directory string|nil The directory to search in. Defaults to the current working directory ('.') if nil.
--- @param confirm boolean|nil If true, prompts for confirmation on each file. Defaults to true.
function M.replace_in_dir(old_term, new_term, directory, confirm)
    -- Set default values for directory and confirmation
    directory = directory or '.'
    confirm = confirm == nil or confirm -- Default to true for confirmation

    -- Construct the ripgrep command to find files containing the old_term.
    -- `--files-with-matches` lists only the file paths.
    -- `--no-messages` suppresses non-matching messages.
    -- `%q` ensures proper quoting for terms that might contain spaces or special characters.
    local rg_cmd = string.format("rg --files-with-matches --no-messages %q %q", old_term, directory)

    -- Execute the ripgrep command using Neovim's system function.
    local files_str = vim.fn.system(rg_cmd)
    local shell_error_code = vim.v.shell_error

    -- Check the ripgrep exit code to distinguish between no matches and actual command failure.
    if shell_error_code == 1 then
        -- Ripgrep returns 1 when no matches are found. This is not an error, but an informational state.
        vim.notify(string.format("No files found containing '%s' in '%s'.", old_term, directory), vim.log.levels.INFO)
        return
    elseif shell_error_code ~= 0 then
        -- Ripgrep returns 2 or higher for actual errors (e.g., command not found, invalid directory).
        vim.notify("Ripgrep command failed. Please ensure 'rg' is installed and in your PATH, and the directory is valid.", vim.log.levels.ERROR)
        return
    end

    -- Parse the output of ripgrep into a table of file paths.
    local files = {}
    for line in files_str:gmatch("([^\n]+)\n?") do
        -- Only add non-empty lines that are not just whitespace
        if line:match("^%S") then
            table.insert(files, line)
        end
    end

    -- If no files were found (this check is technically redundant now due to shell_error_code == 1,
    -- but kept for robustness in case rg behavior changes or for other edge cases).
    if #files == 0 then
        vim.notify(string.format("No files found containing '%s' in '%s'.", old_term, directory), vim.log.levels.INFO)
        return
    end

    -- Escape special characters in old_term and new_term for Neovim's substitute command.
    -- This is crucial to prevent issues with regex metacharacters or path delimiters.
    local escaped_old_term = vim.fn.escape(old_term, '/\\&.~')
    local escaped_new_term = vim.fn.escape(new_term, '/\\&.~')

    -- The substitution command to apply to each file. Note: 'g' for global on line, no 'c' here.
    local substitute_cmd_no_confirm = string.format("%%s/%s/%s/g", escaped_old_term, escaped_new_term)

    -- Store the current buffer number and window number to restore them later.
    local original_buffer = vim.fn.bufnr('%')
    local original_window = vim.fn.winnr()

    local total_files_modified = 0

    -- Iterate through each file found by ripgrep
    for _, file_path in ipairs(files) do
        -- Open the file in the current window. `fnameescape` handles special characters in paths.
        vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

        -- Perform the substitution on the current buffer.
        vim.cmd(substitute_cmd_no_confirm)

        -- Check if the buffer was modified by the substitution.
        if vim.fn.getbufvar('%', '&modified') == 1 then
            if confirm then
                -- Prompt the user for confirmation using a modal dialog.
                -- Options: Yes (save), No (revert), All (save all remaining without prompt), Quit (stop process).
                local choice = vim.fn.confirm(
                    string.format("Save changes to %s?", file_path),
                    "&Yes\n&No\n&All\n&Quit"
                )
                if choice == 1 then -- Yes
                    vim.cmd('write') -- Save changes
                    total_files_modified = total_files_modified + 1
                elseif choice == 2 then -- No
                    vim.cmd('edit!') -- Revert changes
                elseif choice == 3 then -- All
                    vim.cmd('write') -- Save changes for current file
                    total_files_modified = total_files_modified + 1
                    confirm = false -- Disable confirmation for all subsequent files
                elseif choice == 4 then -- Quit
                    break -- Exit the loop immediately
                end
            else
                -- If confirmation is disabled (either initially or after 'All' was chosen), just save.
                vim.cmd('write')
                total_files_modified = total_files_modified + 1
            end
        end
    end

    -- Restore the original window and buffer to return the user to their starting point.
    vim.cmd(string.format('%d wincmd w', original_window)) -- Go back to original window
    vim.cmd(string.format('buffer %d', original_buffer)) -- Go back to original buffer

    vim.notify(string.format("Replacement finished. Modified %d files.", total_files_modified), vim.log.levels.INFO)
end

-- Create a user command in Neovim for easy access to the function.
-- `:RgReplace <old_term> <new_term> [directory] [noconfirm]`
vim.api.nvim_create_user_command('RgReplace', function(opts)
    -- Split the arguments provided to the command.
    -- Removed 'plain = true' to correctly interpret '%s+' as a pattern for whitespace.
    local args = vim.split(opts.args, '%s+')

    -- Validate the number of arguments.
    if #args < 2 then
        vim.notify("Usage: :RgReplace <old_term> <new_term> [directory] [noconfirm]\nExample: :RgReplace old_word new_word . noconfirm", vim.log.levels.ERROR)
        return
    end

    -- Extract the terms and optional directory/confirmation flag.
    local old_term = args[1]
    local new_term = args[2]
    local directory = args[3]
    local confirm = true -- Default to confirmation
    if args[4] and args[4]:lower() == 'noconfirm' then
        confirm = false
    end

    -- Call the main replacement function.
    M.replace_in_dir(old_term, new_term, directory, confirm)
end, {
    nargs = '*', -- Allows any number of arguments
    complete = 'file', -- Enables file path completion for the directory argument
    desc = 'Replace a term in files using ripgrep' -- Description for the command
})

return M

