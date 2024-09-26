local function check_setup()
  local config = require("invokeai.config")
  if not config.key then
    vim.health.error("Missing Key")
    return false
  end
  return true
end

---@param modules string[]
local function prequire(modules)
  local result = true
  for _, module in pairs(modules) do
    local status, _ = pcall(require, module)
    print("checking for " .. module)
    if not status then
      vim.health.error("Dependency " .. module .. " is missing")
      result = false
    end
  end
  return result
end

local M = {}
M.check = function()
  vim.health.start("InvokeAI Report")
  if
      prequire({ "plenary" }) and --Check dependencies
      check_setup()               -- Check configuration
  then
    vim.health.ok("Setup is correct")
  else
    vim.health.error("Setup is incorrect")
  end
end
return M
