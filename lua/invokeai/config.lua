local config = {}



---@class InvokeAiOpts
---@field key_fn? fun():string Function to retrieve the API Key
---@field key? string|nil API Key
---@field provider_opts? table A table of options to pass to the AI provider setup,
---@param opts InvokeAiOpts
function config.setup(opts)
  if opts == nil then
    opts = {}
  end
  if opts.key == nil and opts.key_fn == nil then
    vim.notify("InvokeAI Error: API Key not set. Please provide a valid API key or a function that returns the API key.",
      vim.log.levels.ERROR)
  end
  if opts.key ~= nil then
    config.key = opts.key
  else
    local key_value = opts.key_fn()
    if type(key_value) ~= "string" then
      vim.notify("InvokeAI Error: key_fn must return a string. Received: " .. type(key_value), vim.log.levels.ERROR)
    else
      config.key = key_value
    end
  end
  config.provider_opts = opts.provider_opts
end

return config
