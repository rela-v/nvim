local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local M = {}

-- Configuration
local config = {
    API_KEY = "secret",
    base_url = "http://localhost:8080/notes"
}

-- Utility: Send a request
local function request(method, endpoint, body)
    local headers = string.format("-H 'Content-Type: application/json' -H 'X-API-Key: %s'", config.API_KEY)
    local url = config.base_url .. endpoint
    local data = body and ("-d '" .. vim.fn.json_encode(body) .. "'") or ""
    local cmd = string.format("curl -s -X %s %s %s '%s'", method, headers, data, url)

    local result = vim.fn.system(cmd)
    local status = vim.v.shell_error

    if status ~= 0 then
        vim.notify("Request failed: " .. result, vim.log.levels.ERROR)
        return nil
    end

    return vim.fn.json_decode(result)
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

-- ✏️ Edit buffer (used for create & update)
function M.edit_note_buffer(opts)
    opts = opts or {}
    local is_update = opts.is_update or false
    local note = opts.note or { title = "", tags = {}, content = "" }

    -- Find an existing scratch buffer or create a new one
    local buf = vim.fn.bufadd("New Note")
    vim.api.nvim_set_current_buf(buf)
    
    -- Clear the buffer's contents
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    -- Set the buffer's content now that it is the current buffer
    local lines = {
        "Title: " .. (note.title or ""),
        "Tags: " .. table.concat(note.tags or {}, ", "),
        "",
        "--- Write your content below ---",
        note.content or ""
    }
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Create the autocommand to handle the buffer write
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = buf,
        once = true,
        callback = function()
            -- ... (your existing save logic here) ...
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

            local body = {
                title = title,
                content = content,
                tags = tags
            }

            local res
            if is_update and note.id then
                res = request("PUT", "/" .. note.id, body)
            else
                res = request("POST", "", body)
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
    M.edit_note_buffer({ is_update = false })
end

-- 🔄 Update existing note via buffer
function M.update_note()
    -- Use a Telescope picker to select the note
    local notes_picker = pickers.new({}, {
        prompt_title = "Update Note",
        finder = finders.new_dynamic({
            request("GET", "", nil)
        }, {
            entry_maker = function(note)
                return {
                    value = note,
                    display = string.format("%s | %s", note.id, note.title),
                    ordinal = note.title,
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    M.edit_note_buffer({ is_update = true, note = selection.value })
                end
            end)
            return true
        end
    })
    notes_picker:find()
end

-- 📜 List notes using a simple Vim UI picker
function M.list_notes()
    local res = request("GET", "", nil)
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

-- 🔍 View note by ID in center float
function M.view_note(note_id)
    if not note_id then
        vim.ui.input({ prompt = "Note ID to view: " }, function(id)
            if id then M.view_note(id) end
        end)
        return
    end

    local res = request("GET", "/" .. note_id, nil)
    if not res then
        vim.notify("Note not found", vim.log.levels.ERROR)
        return
    end

    local lines = {
        "📄 " .. res.title,
        "🆔 " .. res.id,
        "🏷️ " .. table.concat(res.tags or {}, ", "),
        string.rep("-", 40),
        res.content
    }

    center_float(lines, { width = 70 })
end

-- ❌ Delete a note by ID
function M.delete_note()
    local notes_picker = pickers.new({}, {
        prompt_title = "Delete Note",
        finder = finders.new_dynamic({
            request("GET", "", nil)
        }, {
            entry_maker = function(note)
                return {
                    value = note,
                    display = string.format("%s | %s", note.id, note.title),
                    ordinal = note.title,
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    local confirm = vim.fn.input("Are you sure you want to delete this note? (y/n): ")
                    if confirm:lower() ~= "y" then return end

                    local res = request("DELETE", "/" .. selection.value.id, nil)
                    if res == nil then
                        vim.notify("Note deleted", vim.log.levels.INFO)
                    else
                        vim.notify("Failed to delete note", vim.log.levels.ERROR)
                    end
                end
            end)
            return true
        end
    })
    notes_picker:find()
end

-- 🏷️ Get notes by tag and pick from list
function M.notes_by_tag()
    vim.ui.input({ prompt = "Tag to search: " }, function(tag)
        if not tag then return end
        local res = request("GET", "/tags/" .. tag, nil)
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
