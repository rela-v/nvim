local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local M = {}

---@class NoteConfig
---@field API_KEY string
---@field base_url string

local config = {
	API_KEY = os.getenv("NOTES_API_KEY"),
	base_url = os.getenv("NOTES_API_URL"),
}

local function request(method, endpoint, body)
	if not config.base_url or not config.API_KEY then
		vim.notify("Missing API config", vim.log.levels.ERROR)
		return nil
	end

	local url = config.base_url .. endpoint
	local cmd = {
		"curl", "-sS", "--fail-with-body", "-X", method,
		"-H", "Content-Type: application/json",
		"-H", "X-API-Key: " .. config.API_KEY,
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

local function split_tags(tag_string)
	local tags = {}
	for tag in string.gmatch(tag_string, "[^,%s]+") do
		table.insert(tags, tag)
	end
	return tags
end

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

  local buf = vim.fn.bufadd(is_update and ("Edit Note: " .. (note.title or "Untitled")) or "New Note")
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local function safe_get(obj, key)
    if type(obj) == "table" then
      local val = obj[key]
      if val == nil then
        return "N/A"
      elseif type(val) == "userdata" then
        return "N/A"
      else
        return tostring(val)
      end
    end
    return "N/A"
  end

  local lines = {
    "Title: " .. (note.title or ""),
    "Tags: " .. table.concat(note.tags or {}, ", "),
  }

  if note.code_location and type(note.code_location) == "table" then
    table.insert(lines, "Git Repo: " .. safe_get(note.code_location, "repo"))
    table.insert(lines, "File Path: " .. safe_get(note.code_location, "file_path"))
    table.insert(lines, "Line: " .. safe_get(note.code_location, "line_number"))
  else
    table.insert(lines, "Git Repo: N/A")
    table.insert(lines, "File Path: N/A")
    table.insert(lines, "Line: N/A")
  end

  table.insert(lines, "")
  table.insert(lines, "--- Write your content below ---")

  local content_str = ""
  if type(note.content) == "string" then
    content_str = note.content
  end

  for _, line in ipairs(split_lines(content_str)) do
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
          file_path = file_path,
          line_number = line_num,
        }
      end

      local content = table.concat(vim.list_slice(new_lines, content_start_idx), "\n")
      local tags = split_tags(tags_line)

      local body = {}

      if is_update then
        if note.type then body["type"] = note.type end
        if title ~= "" then body.title = title end
        if content and content ~= "" then body.content = content end
        if tags and #tags > 0 then body.tags = tags end
        if code_location then body.code_location = code_location end
      else
        body["type"] = note.type or "note"
        body.title = title
        if content and content ~= "" then body.content = content end
        if tags and #tags > 0 then body.tags = tags end
        if code_location then body.code_location = code_location end
      end

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

local function make_picker(opts)
	local notes = opts.notes
	local prompt_title = opts.prompt_title
	local on_select = opts.on_select

	if not notes or vim.tbl_isempty(notes) then
		vim.notify("No notes found", vim.log.levels.INFO)
		return
	end

	pickers.new({}, {
		prompt_title = prompt_title,
		finder = finders.new_table({
			results = notes,
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
				if selection and on_select then
					on_select(selection.value)
				end
			end)
			return true
		end,
	}):find()
end

function M.update_note()
	local res = request("GET", "/items", nil)
	if not res then
		vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
		return
	end

	make_picker({
		notes = res,
		prompt_title = "Update Note",
		on_select = function(note)
			M.edit_note_buffer({ is_update = true, note = note })
		end,
	})
end

function M.list_notes()
	local res = request("GET", "/items", nil)
	if not res then
		vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
		return
	end

	make_picker({
		notes = res,
		prompt_title = "List Notes",
		on_select = function(note)
			M.view_note(note.id)
		end,
	})
end

function M.list_todos()
	local res = request("GET", "/items?tags=todo", nil)
	if not res then
		vim.notify("Failed to fetch TODOs", vim.log.levels.ERROR)
		return
	end

	make_picker({
		notes = res,
		prompt_title = "TODOs",
		on_select = function(todo)
			M.view_note(todo.id)
		end,
	})
end

function M.view_note(note_id)
	if not note_id then
		-- Use telescope to select a note instead of vim.ui.input
		local res = request("GET", "/items", nil)
		if not res then
			vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
			return
		end

		make_picker({
			notes = res,
			prompt_title = "Select Note to View",
			on_select = function(note)
				M.view_note(note.id)
			end,
		})
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

	-- Defensive check for code_location: only use if it's a table, not userdata
	if type(res.code_location) == "table" and res.code_location.file_path then
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


function M.delete_note()
	local res = request("GET", "/items", nil)
	if not res then
		vim.notify("Failed to fetch notes", vim.log.levels.ERROR)
		return
	end

	make_picker({
		notes = res,
		prompt_title = "Delete Note",
		on_select = function(note)
			vim.ui.input({
				prompt = "Are you sure you want to delete this note? (y/n): ",
			}, function(confirm)
				if not confirm or confirm:lower() ~= "y" then
					vim.notify("Deletion cancelled", vim.log.levels.INFO)
					return
				end

				local del_res = request("DELETE", "/items/" .. note.id, nil)
				if del_res ~= nil then
					vim.notify("Note deleted", vim.log.levels.INFO)
				else
					vim.notify("Failed to delete note", vim.log.levels.ERROR)
				end
			end)
		end,
	})
end

function M.notes_by_tag()
  -- 1. Fetch ALL notes
  local notes = request("GET", "/items", nil)
  if not notes or vim.tbl_isempty(notes) then
    vim.notify("No notes found", vim.log.levels.INFO)
    return
  end

  -- 2. Extract all unique tags from notes
  local tag_set = {}
  for _, note in ipairs(notes) do
    if note.tags and type(note.tags) == "table" then
      for _, tag in ipairs(note.tags) do
        tag_set[tag] = true
      end
    end
  end

  -- 3. Convert tag_set keys to list
  local tags = {}
  for tag, _ in pairs(tag_set) do
    table.insert(tags, tag)
  end

  -- 4. Show tag picker with Telescope
  local pick_tag = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if not selection or not selection.value then
      return
    end

    local chosen_tag = selection.value

    -- 5. Filter notes by chosen tag
    local filtered_notes = {}
    for _, note in ipairs(notes) do
      if note.tags and vim.tbl_contains(note.tags, chosen_tag) then
        table.insert(filtered_notes, note)
      end
    end

    -- 6. Show filtered notes picker
    make_picker({
      notes = filtered_notes,
      prompt_title = "Notes tagged: " .. chosen_tag,
      on_select = function(note)
        M.view_note(note.id)
      end,
    })
  end

  pickers.new({}, {
    prompt_title = "Select Tag",
    finder = finders.new_table({
      results = tags,
      entry_maker = function(tag)
        return {
          value = tag,
          display = tag,
          ordinal = tag,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        pick_tag(prompt_bufnr)
      end)
      return true
    end,
  }):find()
end


function M.go_to_todo_location()
	local todos = request("GET", "/items?tags=todo", nil)
	if not todos then
		vim.notify("Failed to fetch TODOs", vim.log.levels.ERROR)
		return
	end

	local entries = {}
	for _, todo in ipairs(todos) do
		if todo.code_location and todo.code_location.file_path then
			table.insert(entries, todo)
		end
	end

	if vim.tbl_isempty(entries) then
		vim.notify("No TODOs with code locations found.", vim.log.levels.INFO)
		return
	end

	pickers.new({}, {
		prompt_title = "Select a TODO to jump to:",
		finder = finders.new_table({
			results = entries,
			entry_maker = function(todo)
				return {
					value = todo,
					display = string.format(
						"%s:%s | %s",
						todo.code_location.file_path,
						todo.code_location.line_number,
						todo.title
					),
					ordinal = todo.title,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if not selection then return end

				local location = selection.value.code_location
				local target_path = vim.fn.resolve(vim.fn.fnamemodify(location.file_path, ":p"))

				if vim.fn.filereadable(target_path) == 0 then
					vim.notify("File not found: " .. target_path, vim.log.levels.ERROR)
					return
				end

				vim.cmd("edit " .. target_path)
				if location.line_number then
					vim.cmd(tostring(location.line_number))
				end
				vim.notify("Jumped to line " .. (location.line_number or "?") .. " in " .. location.file_path, vim.log.levels.INFO)
			end)
			return true
		end,
	}):find()
end

function M.setup(user_config)
	config.API_KEY = user_config.API_KEY or config.API_KEY
	config.base_url = user_config.base_url or config.base_url
end

return M

