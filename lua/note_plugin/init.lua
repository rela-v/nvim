local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local M = {}

---@class NoteConfig
---@field API_KEY string
---@field base_url string

-- Configuration
local config = {
	API_KEY = os.getenv("NOTES_API_KEY"),
	base_url = os.getenv("NOTES_API_URL"),
}

--- Utility: Send a request
---@param method string
---@param endpoint string
---@param body table | nil
---@return table | nil
local function request(method, endpoint, body)
	if not config.base_url or not config.API_KEY then
		vim.notify("Missing API config", vim.log.levels.ERROR)
		return nil
	end

	local url = config.base_url .. endpoint

	local cmd = {
		"curl",
		"-sS",
		"--fail-with-body",
		"-X",
		method,
		"-H",
		"Content-Type: application/json",
		"-H",
		"X-API-Key: " .. config.API_KEY,
		url,
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
		return {}
	end

	local ok, parsed = pcall(vim.fn.json_decode, result)
	if not ok then
		vim.notify("Failed to decode response: " .. result, vim.log.levels.ERROR)
		return nil
	end

	return parsed
end

--- Floating UI helper (centered scratch buffer)
---@param lines string[]
---@param opts table | nil
local function center_float(lines, opts)
	opts = opts or {}
	local width = opts.width or 60
	local height = #lines + 4
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
end

--- Helper: tag parsing
---@param tag_string string
---@return string[]
local function split_tags(tag_string)
	local tags = {}
	for tag in string.gmatch(tag_string, "[^,%s]+") do
		table.insert(tags, tag)
	end
	return tags
end

---@param str string | nil
---@return string[]
local function split_lines(str)
	if not str or str == "" then
		return {}
	end
	local t = {}
	for line in string.gmatch(str, "([^\n\r]+)") do
		table.insert(t, line)
	end
	return t
end

--- Edit buffer (used for create & update)
---@param opts table | nil
function M.edit_note_buffer(opts)
	opts = opts or {}
	local is_update = opts.is_update or false
	local note = opts.note or {
		title = "",
		tags = {},
		content = "",
		type = opts.type or "note",
		code_location = nil,
	}

	local buf = vim.fn.bufadd("New Note")
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	local lines = {
		"Title: " .. (note.title or ""),
		"Tags: " .. table.concat(note.tags or {}, ", "),
	}

	if note.code_location then
		table.insert(lines, "Git Repo: " .. (note.code_location.repo or "N/A"))
		table.insert(lines, "File Path: " .. (note.code_location.file_path or "N/A"))
		table.insert(lines, "Line: " .. (note.code_location.line_number or "N/A"))
	end

	table.insert(lines, "")
	table.insert(lines, "--- Write your content below ---")

	for _, line in ipairs(split_lines(note.content or "")) do
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = buf,
		once = true,
		callback = function()
			local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local title, tags_line, content_start_idx = "", "", 0
			local git_repo, file_path, line_num = nil, nil, nil

			for i, line in ipairs(new_lines) do
				if line:match("^Title:") then
					title = line:gsub("^Title:%s*", "")
				elseif line:match("^Tags:") then
					tags_line = line:gsub("^Tags:%s*", "")
				elseif line:match("^Git Repo:") then
					git_repo = line:gsub("^Git Repo:%s*", "")
				elseif line:match("^File Path:") then
					file_path = line:gsub("^File Path:%s*", "")
				elseif line:match("^Line:") then
					local line_str = line:gsub("^Line:%s*", "")
					local num = tonumber(line_str)
					if num and type(num) == "number" then
						line_num = num
					else
						vim.notify("Invalid line number: " .. line_str, vim.log.levels.WARN)
					end
				elseif line:match("^%-%-%-") then
					content_start_idx = i + 1
					break
				end
			end

			local code_location = nil
			if file_path and line_num then
				code_location = {
					repo = git_repo,
					file_path = file_path,
					line_number = line_num,
				}
			end

			local content = table.concat(vim.list_slice(new_lines, content_start_idx), "\n")
			local tags = split_tags(tags_line)

			local body = {
				type = note.type,
				title = title,
				content = content,
				tags = tags,
				code_location = code_location,
			}

			local res
			if is_update and note.id then
				res = request("PUT", "/items/" .. note.id, body)
			else
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

--- Create a new note
function M.create_note()
	local note = {
		title = "",
		tags = {},
		content = "",
		type = "note",
		code_location = nil,
	}
	M.edit_note_buffer({ is_update = false, note = note })
end

--- Create a TODO from current line
function M.create_todo()
	local line_content = vim.api.nvim_get_current_line()
	local file_path = vim.fn.expand("%:p")
	local line_number = vim.fn.line(".")

	local repo_url = vim.fn.system({ "git", "config", "--get", "remote.origin.url" }):gsub("^%s*(.-)%s*$", "%1")
	if vim.v.shell_error ~= 0 or repo_url == "" then
		repo_url = nil
	end

	local code_location = {
		repo = repo_url,
		file_path = vim.fn.fnamemodify(file_path, ":~:."),
		line_number = line_number,
	}

	local note = {
		title = "TODO",
		tags = { "todo" },
		content = line_content,
		type = "todo",
		code_location = code_location,
	}

	M.edit_note_buffer({ is_update = false, note = note })
end

--- Update existing note via Telescope
function M.update_note()
	local res = request("GET", "/items", nil)
	if not res then
		vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
		return
	end

	pickers.new({}, {
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
	}):find()
end

--- List notes
function M.list_notes()
	local res = request("GET", "/items", nil)
	if not res then
		return
	end

	local entries = {}
	for _, note in ipairs(res) do
		table.insert(entries, { value = note, text = string.format("%s | %s", note.id, note.title) })
	end

	vim.ui.select(entries, {
		prompt = "Select a note to view:",
		format_item = function(item)
			return item.text
		end,
	}, function(choice)
		if choice then
			M.view_note(choice.value.id)
		end
	end)
end

--- List TODOs
function M.list_todos()
	local res = request("GET", "/items?tags=todo", nil)
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
		format_item = function(item)
			return item.text
		end,
	}, function(choice)
		if choice then
			M.view_note(choice.value.id)
		end
	end)
end

--- View note by ID
---@param note_id string | nil
function M.view_note(note_id)
	if not note_id then
		vim.ui.input({ prompt = "Note ID to view: " }, function(id)
			if id then
				M.view_note(id)
			end
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

	if res.code_location and res.code_location.file_path then
		table.insert(lines, "Git Repo: " .. (res.code_location.repo or "N/A"))
		table.insert(lines, "File Path: " .. res.code_location.file_path)
		table.insert(lines, "Line: " .. (res.code_location.line_number or "N/A"))
		table.insert(lines, "")
	end

	for _, line in ipairs(split_lines(res.content or "")) do
		table.insert(lines, line)
	end

	center_float(lines, { width = 70 })
end

--- Delete a note
function M.delete_note()
	local res = request("GET", "/items", nil)
	if not res then
		vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
		return
	end

	pickers.new({}, {
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
					if confirm:lower() ~= "y" then
						return
					end

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
	}):find()
end

--- Filter notes by tag
function M.notes_by_tag()
	vim.ui.input({ prompt = "Tag to search: " }, function(tag)
		if not tag then
			return
		end
		local encoded_tag = tag:gsub(" ", "%%20") -- workaround for lack of vim.fn.urlencode
		local res = request("GET", "/items?tags=" .. encoded_tag, nil)
		if not res then
			return
		end

		local entries = {}
		for _, note in ipairs(res) do
			table.insert(entries, { value = note, text = string.format("%s | %s", note.id, note.title) })
		end

		vim.ui.select(entries, {
			prompt = "Notes with tag '" .. tag .. "'",
			format_item = function(item)
				return item.text
			end,
		}, function(choice)
			if choice then
				M.view_note(choice.value.id)
			end
		end)
	end)
end

--- Jump to code location of TODO
function M.go_to_todo_location()
	local todos = request("GET", "/items?tags=todo", nil)
	if not todos then
		vim.notify("Failed to fetch TODOs", vim.log.levels.ERROR)
		return
	end

	local entries = {}
	for _, todo in ipairs(todos) do
		if todo.code_location and todo.code_location.file_path then
			table.insert(entries, {
				value = todo,
				text = string.format(
					"%s:%s | %s",
					todo.code_location.file_path,
					todo.code_location.line_number,
					todo.title
				),
			})
		end
	end

	if #entries == 0 then
		vim.notify("No TODOs with code locations found.", vim.log.levels.INFO)
		return
	end

	vim.ui.select(entries, {
		prompt = "Select a TODO to jump to:",
		format_item = function(item)
			return item.text
		end,
	}, function(choice)
		if not choice then
			return
		end
		local location = choice.value.code_location
		local target_path = vim.fn.resolve(vim.fn.fnamemodify(location.file_path, ":p"))

		if vim.fn.filereadable(target_path) == 0 then
			vim.notify("File not found: " .. target_path, vim.log.levels.ERROR)
			return
		end

		vim.cmd("e " .. target_path .. " | " .. tostring(location.line_number))
		vim.notify("Jumped to line " .. location.line_number .. " in " .. location.file_path, vim.log.levels.INFO)
	end)
end

--- Setup
---@param user_config NoteConfig
function M.setup(user_config)
	config.API_KEY = user_config.API_KEY or config.API_KEY
	config.base_url = user_config.base_url or config.base_url
end

return M
