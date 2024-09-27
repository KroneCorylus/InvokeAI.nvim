local function markvisual()
  local ESC_FEEDKEY = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(ESC_FEEDKEY, 'n', true)
  vim.api.nvim_feedkeys('gv', 'x', false)
  vim.api.nvim_feedkeys(ESC_FEEDKEY, 'n', true)
end

--- @module 'invokeai.utils'
local utils = {}

--- Closes a collection of windows.
--- @param wins number[]: A table containing window IDs to close.
utils.close = function(wins)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
end

---@param float number
---@return integer
utils.round = function(float)
  return math.floor(float + .5)
end


---@param buffer number
---@return string
utils.buffer_to_string = function(buffer)
  local content = vim.api.nvim_buf_get_lines(buffer, 0, vim.api.nvim_buf_line_count(buffer), false)
  return table.concat(content, "\n")
end


---@param input string
---@return string|nil, string
utils.extract_file_type_and_code_content = function(input)
  local filetype, textWithoutFileType = input:match("```(.-)%s*[\n](.*)```")
  if filetype then
    return filetype, textWithoutFileType
  else
    return nil, input
  end
end


---@param str string
---@return string[]
utils.text_to_lines = function(str)
  local lines = {}
  for line in string.gmatch(str, "([^\n]*)\n?") do
    table.insert(lines, line)
  end
  return lines
end


---@param str string
---@param buf integer
---@param start? integer
utils.write_to_buffer = function(str, buf, start)
  start = start or 0
  local lines = utils.text_to_lines(str)
  vim.api.nvim_buf_set_lines(buf, start, -1, false, lines)
end

--- @return string[], number, number; lines, start_row, end_row
function utils.get_visual_selection()
  markvisual()
  local _, start_row, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, end_row, cecol, _ = unpack(vim.fn.getpos("'>"))
  local lines = vim.fn.getline(start_row, end_row)
  if type(lines) == "string" then
    lines = { lines }
  end
  if lines[1] == nil then
    lines = { "" }
  end
  return lines, start_row, end_row
end

return utils;
