local utils = require("invokeai.utils")
return function(body, context)
  print("replace resolver")
  local _, result = utils.extract_file_type_and_code_content(body.choices[1].message.content);
  vim.api.nvim_buf_set_lines(context.origin_buf, context.start_row - 1, context.end_row, false,
    utils.text_to_lines(result))
  context:destroy()
end
