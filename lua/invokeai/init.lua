-- local function prequire(...)
--   local status, lib = pcall(require, ...)
--   if (status) then return lib end
--   --Library failed to load, so perhaps return `nil` or something?
--   return nil
-- end
local curl = require("plenary.curl")
local utils = require("invokeai.utils")
local windows = require("invokeai.windows")
local context = require("invokeai.context")
local key = ""
-- local lol = prequire("pepe")
-- if lol == nil then
--   print("Pepe no esta presente")
-- end


-- for _, file in ipairs(luaFiles) do
--   print(file)
-- end


---@alias message {role:string, content:string }

--- @param data string
--- @param _context Context
--- @return { model: string, messages: message[] }
local function get_payload(data, _context)
  local filetype = _context.filetype or ""
  return {
    model = "gpt-4o-mini",
    messages = {
      {
        role = "system",
        content = "Respond only in valid " .. filetype .. " code"
      },
      {
        role = "user",
        content = data
      }
    }
  }
end

---Creates a table of HTTP headers.
--- @return Table; table containing the HTTP headers.
local function get_headers()
  return {
    ["Content-Type"] = "application/json",
    ["Authorization"] =
        "Bearer " .. key
  }
end

--- Constructs a formatted prompt string with code in a specified language.
--- @param prompt string|number; The prompt text or a buffer number to retrieve the text.
--- @param code string|number|nil; The code text or a buffer number to retrieve the text.
--- @param lang string|nil; The programming language, defaults to empty string if nil.
--- @return string; The formatted prompt string with code.
local function get_prompt(prompt, code, lang)
  if type(prompt) == "number" then
    prompt = utils.buffer_to_string(prompt)
  end
  if type(code) == "number" then
    lang = vim.api.nvim_get_option_value('filetype', { buf = code })
    code = utils.buffer_to_string(code)
  end
  if lang == nil then
    lang = ""
  end
  if code ~= nil and code ~= "" then
    return prompt .. "\n\n```" .. lang .. "\n" .. code .. "\n```"
  end
  return prompt
end

--- @param payload table; body of the request
--- @param ctx Context; contexto
local function send(payload, ctx)
  curl.post("https://api.openai.com/v1/chat/completions", {
    body = vim.json.encode(payload),
    headers = get_headers(),
    callback = function(response)
      local body = vim.json.decode(response.body);
      vim.schedule(function()
        ctx.resolve_fn(body, ctx)
      end)
    end
  })
end

--- @return string[], number, number; lines, start_row, end_row
local function get_visual_selection()
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



local function markvisual()
  local ESC_FEEDKEY = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(ESC_FEEDKEY, 'n', true)
  vim.api.nvim_feedkeys('gv', 'x', false)
  vim.api.nvim_feedkeys(ESC_FEEDKEY, 'n', true)
end

local invokeai = {}

invokeai.debug = function()
  vim.cmd("Bmessagesvs")
  local window_key = vim.api.nvim_replace_termcodes('<C-w>', true, false, true)
  vim.api.nvim_feedkeys(window_key .. "x", 'n', false)
  vim.api.nvim_feedkeys("40" .. window_key .. ">", 'n', false)
end

invokeai.setup = function(opts)
  if opts == nil then
    opts = {}
  end
  if opts.key_fn ~= nil then
    key = opts.key_fn()
  end
end

invokeai.reset = function()
  local info = debug.getinfo(1, "S").source
  local file_path = info:sub(2) -- Remove the "@" character at the start
  local file_dir = file_path:match("(.*/)")
  local handle = io.popen("find " .. file_dir .. " -name \"*.lua\"")
  local result = ""
  if handle ~= nil then
    result = handle:read("*a")
    handle:close()
  end
  local modules = {}
  for file in result:gmatch("[^\n]+") do
    file = string.sub(file, #file_dir + 1, -5)
    file = string.gsub(file, "/", ".")
    if file == "init" then
      file = "invokeai"
    end
    table.insert(modules, file)
  end
  for _, module in pairs(modules) do
    print(module)
    package.loaded[module] = nil
  end
end

invokeai.pre_prompt = function(prompt, options)
  markvisual()
  local _context = context.new(vim.api.nvim_get_current_buf(), options)
  _context.original_lines, _context.start_row, _context.end_row = get_visual_selection()
  print("original_lines")
  local code = table.concat(_context.original_lines, "\n")
  print("CODE", code)
  local data = get_prompt(prompt, code, _context.filetype)
  local payload = get_payload(data, _context.filetype)
  send(payload, _context)
end

invokeai.popup = function(options)
  markvisual()
  local _context = context.new(vim.api.nvim_get_current_buf(), options)
  _context.original_lines, _context.start_row, _context.end_row = get_visual_selection()

  vim.api.nvim_buf_set_lines(_context.code_buf, 0, -1, false, _context.original_lines)
  local code_win = vim.api.nvim_open_win(_context.code_buf, true, windows.get_code_win_conf())
  vim.api.nvim_set_option_value('filetype', _context.filetype, { buf = _context.code_buf })
  local prompt_win = vim.api.nvim_open_win(_context.prompt_buf, true, windows.get_prompt_win_conf(code_win))

  local autocmd_prompt = vim.api.nvim_create_autocmd("WinClosed", {
    buffer = _context.prompt_buf,
    callback = function()
      print("autocmd WinBufLeave prompt_buf")
      utils.close({ code_win, prompt_win })
      _context:destroy()
    end
  })

  local autocmd_code = vim.api.nvim_create_autocmd("WinClosed", {
    buffer = _context.code_buf,
    callback = function()
      print("autocmd WinBufLeave code_buf")
      utils.close({ code_win, prompt_win })
      _context:destroy()
    end
  })

  vim.keymap.set({ 'n', 'i', 's' }, '<C-x>', function()
      utils.close({ code_win, prompt_win })
      _context:destroy()
    end,
    { buffer = _context.prompt_buf, desc = 'close win' })
  vim.keymap.set({ 'n', 'i', 's' }, '<C-s>', function()
    local data = get_prompt(_context.prompt_buf, _context.code_buf);
    local payload = get_payload(data, _context)
    send(payload, _context)
    vim.api.nvim_del_autocmd(autocmd_prompt)
    vim.api.nvim_del_autocmd(autocmd_code)
    utils.close({ code_win, prompt_win })
  end, { buffer = _context.prompt_buf, desc = 'send prompt' })
end

return invokeai