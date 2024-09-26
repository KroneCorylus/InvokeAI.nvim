Context = {}
Context.__index = Context

---@class Context
---@field filetype string?
---@field origin_buf number
---@field prompt_buf number
---@field code_buf number
---@field start_row number?
---@field end_row number?
---@field original_lines string[]?
---@field resolve_fn function
---@field destroy function
---@field new function

---@class ContextOptions
---@field resolve_fn function?; function to process the response from openai.
---@field filetype string?; force a filetype



---@param origin_buf number; The origin buffer, where the text is sampled from.
---@param options ContextOptions|nil
---@return Context
function Context.new(origin_buf, options)
  assert(origin_buf, "origin_buf is required")
  local instance = setmetatable({}, Context)
  instance.filetype = nil
  instance.start_row = nil
  instance.end_row = nil
  instance.original_lines = nil
  instance.origin_buf = origin_buf
  instance.prompt_buf = vim.api.nvim_create_buf(false, true);
  instance.code_buf = vim.api.nvim_create_buf(false, true);
  if options == nil then
    options = {}
  end
  instance.resolve_fn = options.resolve_fn or require("invokeai.resolvers.float")
  if options.filetype ~= nil then
    instance.filetype = options.filetype
  else
    if vim.api.nvim_buf_is_valid(origin_buf) then
      instance.filetype = vim.api.nvim_get_option_value('filetype', { buf = origin_buf })
    end
  end
  return instance
end

function Context:destroy()
  if vim.api.nvim_buf_is_valid(self.prompt_buf) then
    vim.api.nvim_buf_delete(self.prompt_buf, { force = true })
  end
  if vim.api.nvim_buf_is_valid(self.code_buf) then
    vim.api.nvim_buf_delete(self.code_buf, { force = true })
  end
  -- Clear instance properties to remove any strong references
  self.origin_buf = nil
  self.prompt_buf = nil
  self.code_buf = nil
  self.filetype = nil
  self.start_row = nil
  self.end_row = nil
  self.original_lines = nil
  self.resolve_fn = nil
end

return Context
