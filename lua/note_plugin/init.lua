local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local M = {}

-- Configuration
local config = {
    API_KEY = os.getenv("NOTES_API_KEY"),
    base_url = os.getenv("NOTES_API_URL")
}

-- Utility: Send a request
local function request(method, endpoint, body)
    if not config.base_url or not config.API_KEY then
        vim.notify("Missing API config", vim.log.levels.ERROR)
        return nil
    end

    local url = config.base_url .. endpoint

    local cmd = {
        "curl",
        "-sS",  -- Silent but show errors
        "--fail-with-body",  -- Makes curl exit non-zero on HTTP errors (and keeps body)
        "-X", method,
        "-H", "Content-Type: application/json",
        "-H", "X-API-Key: " .. config.API_KEY,
        url
    }

    if body then
        table.insert(cmd, 6, "-d")
        table.insert(cmd, 7, vim.fn.json_encode(body))
    end

    local result = vim.fn.system(cmd)
    local status = vim.v.shell_error

    if status ~= 0 then
        vim.notify("Request failed: " .. result, vim.log.levels.ERROR)
        return nil
    end

    if not result or result == "" then
        return {} -- OK, empty response (e.g. DELETE)
    end

    local ok, parsed = pcall(vim.fn.json_decode, result)
    if not ok then
        vim.notify("Failed to decode response: " .. result, vim.log.levels.ERROR)
        return nil
    end

    return parsed
end

---

-- 🧠 Floating UI helper (centered scratch buffer)
local function center_float(lines, opts)
    opts = opts or {}
    local width = opts.width or 60
    local height = #lines + 4
    local win_width = vim.o.columns
    local win_height = vim.o.lines

    local row = math.floor((win_height - height) / 2)
    local col = math.floor((win_width - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    })

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
end

---

-- 🛠️ Helper: tag parsing
local function split_tags(tag_string)
    local tags = {}
    for tag in string.gmatch(tag_string, '([^,%s]+)') do
        table.insert(tags, tag)
    end
    return tags
end

local function split_lines(str)
    if not str or str == "" then return {} end
    local t = {}
    for line in string.gmatch(str, "([^\n\r]+)") do
        table.insert(t, line)
    end
    return t
end

-- ✏️ Edit buffer (used for create & update)
function M.edit_note_buffer(opts)
    opts = opts or {}
    local is_update = opts.is_update or false
    local note = opts.note or { title = "", tags = {}, content = "", item_type = opts.item_type or "note", code_location = nil }

    -- Find an existing scratch buffer or create a new one
    local buf = vim.fn.bufadd("New Note")
    vim.api.nvim_set_current_buf(buf)
    
    -- Clear the buffer's contents
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    -- Build lines for the buffer, including code location if present
    local lines = {
        "Title: " .. (note.title or ""),
        "Tags: " .. table.concat(note.tags or {}, ", "),
    }

    if note.code_location then
        table.insert(lines, "Git Repo: " .. (note.code_location.repo or "N/A"))
        table.insert(lines, "File Path: " .. (note.code_location.path or "N/A"))
        table.insert(lines, "Line: " .. (note.code_location.line or "N/A"))
    end
    
    table.insert(lines, "")
    table.insert(lines, "--- Write your content below ---")

    local content_lines = split_lines(note.content or "")
    for _, line in ipairs(content_lines) do
        table.insert(lines, line)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Create the autocommand to handle the buffer write
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = buf,
        once = true,
        callback = function()
            local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local title = new_lines[1]:gsub("^Title:%s*", "")
            local tags_line = new_lines[2]:gsub("^Tags:%s*", "")
            local content_start = 0

            for i, line in ipairs(new_lines) do
                if line:match("^%-%-%-") then
                    content_start = i + 1
                    break
                end
            end

            local content = table.concat(vim.list_slice(new_lines, content_start), "\n")
            local tags = split_tags(tags_line)
            
            -- Preserve code location from original note
            local code_location = note.code_location

            local res
            if is_update and note.id then
                local body = {
                    item_type = note.item_type,
                    title = title,
                    content = content,
                    tags = tags,
                    code_location = code_location
                }
                res = request("PUT", "/items/" .. note.id, body)
            else
                local body = {
                    item_type = note.item_type,
                    title = title,
                    content = content,
                    tags = tags,
                    code_location = code_location
                }
                res = request("POST", "/items", body)
            end

            if res then
                vim.notify(is_update and "Note updated!" or "Note created!", vim.log.levels.INFO)
                vim.api.nvim_buf_delete(buf, { force = true })
            else
                vim.notify("Failed to save note", vim.log.levels.ERROR)
            end
        end,
    })
end

---

-- 📝 Create a new note via buffer
function M.create_note()
    local note = {
        title = "",
        tags = {},
        content = "",
        item_type = "note",
        code_location = nil
    }
    M.edit_note_buffer({ is_update = false, note = note })
end

-- ✅ Create a new TODO item from current line, including file path and line number
function M.create_todo()
    local line_content = vim.api.nvim_get_current_line()
    local file_path = vim.fn.expand('%:p')
    local line_number = vim.fn.line('.')
    
    -- Get the git remote URL, if available
    local repo_url_cmd = { "git", "config", "--get", "remote.origin.url" }
    local repo_url = vim.fn.system(repo_url_cmd)
    
    -- Check for errors or empty output
    if vim.v.shell_error ~= 0 or not repo_url or repo_url == "" then
        repo_url = nil
    end

    local code_location = {
        repo = repo_url,
        path = vim.fn.fnamemodify(file_path, ":~:."),
        line = line_number
    }
    
    local note = {
        title = "TODO",
        tags = { "todo" },
        content = line_content,
        item_type = "todo",
        code_location = code_location
    }
    M.edit_note_buffer({ is_update = false, note = note })
end

-- 🔄 Update existing note via buffer
function M.update_note()
    -- Use a Telescope picker to select the note
    local res = request("GET", "/items", nil)
    if not res then
        vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
        return
    end

    local notes_picker = pickers.new({}, {
        prompt_title = "Update Note",
        finder = finders.new_table({
            results = res,
            entry_maker = function(note)
                return {
                    value = note,
                    display = string.format("%s | %s", note.id, note.title),
                    ordinal = note.title,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    M.edit_note_buffer({ is_update = true, note = selection.value })
                end
            end)
            return true
        end,
    })

    notes_picker:find()
end

-- 📜 List notes using a simple Vim UI picker
function M.list_notes()
    local res = request("GET", "/items", nil)
    if not res then return end

    local entries = {}
    for _, note in ipairs(res) do
        table.insert(entries, { value = note, text = string.format("%s | %s", note.id, note.title) })
    end

    vim.ui.select(entries, {
        prompt = "Select a note to view:",
        format_item = function(item) return item.text end
    }, function(choice)
        if choice then
            M.view_note(choice.value.id)
        end
    end)
end

-- 📋 List all TODO items using a simple Vim UI picker
function M.list_todos()
    -- Request all items with item_type="todo"
    local res = request("GET", "/items?type=todo", nil)
    if not res then
        vim.notify("Failed to fetch TODOs", vim.log.levels.ERROR)
        return
    end

    local entries = {}
    for _, todo in ipairs(res) do
        table.insert(entries, { value = todo, text = string.format("%s | %s", todo.id, todo.title) })
    end

    vim.ui.select(entries, {
        prompt = "Select a TODO to view:",
        format_item = function(item) return item.text end
    }, function(choice)
        if choice then
            M.view_note(choice.value.id)
        end
    end)
end

-- 🔍 View note by ID in center float
function M.view_note(note_id)
    if not note_id then
        vim.ui.input({ prompt = "Note ID to view: " }, function(id)
            if id then M.view_note(id) end
        end)
        return
    end

    local res = request("GET", "/items/" .. note_id, nil)
    if not res then
        vim.notify("Note not found", vim.log.levels.ERROR)
        return
    end

    local lines = {
        "📄 " .. res.title,
        "🆔 " .. res.id,
        "🏷️ " .. table.concat(res.tags or {}, ", "),
        string.rep("-", 40),
    }

    -- Split content into multiple lines and append
    local content_lines = split_lines(res.content or "")
    for _, line in ipairs(content_lines) do
        table.insert(lines, line)
    end

    center_float(lines, { width = 70 })
end

-- ❌ Delete a note by ID
function M.delete_note()
    local res = request("GET", "/items", nil)
    if not res then
        vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
        return
    end

    local notes_picker = pickers.new({}, {
        prompt_title = "Delete Note",
        finder = finders.new_table({
            results = res,
            entry_maker = function(note)
                return {
                    value = note,
                    display = string.format("%s | %s", note.id, note.title),
                    ordinal = note.title,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    local confirm = vim.fn.input("Are you sure you want to delete this note? (y/n): ")
                    if confirm:lower() ~= "y" then return end

                    local res = request("DELETE", "/items/" .. selection.value.id, nil)
                    if res == nil then
                        vim.notify("Note deleted", vim.log.levels.INFO)
                    else
                        vim.notify("Failed to delete note", vim.log.levels.ERROR)
                    end
                end
            end)
            return true
        end,
    })

    notes_picker:find()
end

-- 🏷️ Get notes by tag and pick from list
function M.notes_by_tag()
    vim.ui.input({ prompt = "Tag to search: " }, function(tag)
        if not tag then return end
        
        -- Corrected endpoint to use query parameters
        local res = request("GET", "/items?tags=" .. vim.fn.urlencode(tag), nil)
        if not res then return end

        local entries = {}
        for _, note in ipairs(res) do
            table.insert(entries, { value = note, text = string.format("%s | %s", note.id, note.title) })
        end

        vim.ui.select(entries, {
            prompt = "Notes with tag '" .. tag .. "'",
            format_item = function(item) return item.text end
        }, function(choice)
            if choice then
                M.view_note(choice.value.id)
            end
        end)
    end)
end

---

-- 🔧 Setup
function M.setup(user_config)
    config.API_KEY = user_config.API_KEY or config.API_KEY
    config.base_url = user_config.base_url or config.base_url
end

return M

