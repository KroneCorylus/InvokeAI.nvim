local utils = require("invokeai.utils")
local ui = vim.api.nvim_list_uis()[1];
local windows = {}

windows.get_result_win_conf = function()
  return {
    relative = "editor",
    width = utils.round(ui.width * 0.5),
    height = utils.round(ui.height) - 4,
    col = utils.round(ui.width * 0.5),
    row = 0,
    title = "Result",
    -- focusable = false,
    border = "rounded",
    style = 'minimal',
  }
end
windows.get_code_win_conf = function()
  return {
    relative = "editor",
    width = utils.round(ui.width * 0.5),
    height = utils.round(ui.height * 0.75) - 6,
    col = utils.round(ui.width * 0.25),
    row = 5,
    title = "Code:",
    -- focusable = false,
    border = "single",
    style = 'minimal',
  }
end
windows.get_prompt_win_conf = function(win)
  return {
    relative = "win",
    width = utils.round(ui.width * 0.5),
    height = 2,
    col = -1,
    row = -1,
    style = 'minimal',
    title = "Prompt:",
    -- focusable = false,
    border = "rounded",
    anchor = "SW",
    win = win
  }
end

return windows
