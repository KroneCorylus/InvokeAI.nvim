local config = {}


---@class InvokeAiOpts
---@field key_fn? fun():string Function to retrieve the API Key
---@field key? string API Key
---@field provider? table AI Provider module
---@field provider_opts? table A table of options to pass to the AI provider setup

local function get_key_from_opts(opts)
  if opts.key == nil and opts.key_fn == nil then
    vim.notify("InvokeAI Error: API Key not set. Please provide a valid API key or a function that returns the API key.",
      vim.log.levels.ERROR)
    return nil
  end
  if opts.key ~= nil then
    return opts.key
  else
    local key_value = opts.key_fn()
    if type(key_value) ~= "string" then
      vim.notify("InvokeAI Error: key_fn must return a string. Received: " .. type(key_value), vim.log.levels.ERROR)
      return nil
    else
      return key_value
    end
  end
end

---@param opts InvokeAiOpts
function config.setup(opts)
  if opts == nil then
    opts = {}
  end
  local key = get_key_from_opts(opts)
  config.provider = opts.provider or require("invokeai.providers.openai")
  local provider_opts = opts.provider_opts or {}
  provider_opts.key = key
  config.provider.setup(provider_opts)
end

return config
