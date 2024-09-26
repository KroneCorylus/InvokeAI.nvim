local utils = require("invokeai.utils")
local windows = require("invokeai.windows")

return function(body, context)
  print("float resolver")
  local filetype, result = utils.extract_file_type_and_code_content(body.choices[1].message.content);
  local result_buf = vim.api.nvim_create_buf(false, true);
  utils.write_to_buffer(result, result_buf);
  if context.filetype ~= nil then
    vim.api.nvim_buf_set_option(result_buf, 'filetype', context.filetype)
  end
  if filetype ~= nil then
    vim.api.nvim_buf_set_option(result_buf, 'filetype', filetype)
  end
  vim.api.nvim_open_win(result_buf, true, windows.get_result_win_conf())

  -- vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace('dis.result_ns'), 0, 0,
  --   { id = 1, virt_lines_above = true, hl_group = 'Comment', virt_lines = { { { "<C-s>", "Error" } }, { { "<C-x>", "Error" } } } })


  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = result_buf,
    callback = function()
      print("autocmd WinClosed result_buf")
      context:destroy()
    end
  })
end
