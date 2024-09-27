local openai = {}

---@alias message {role:string, content:string }

---Creates a table of HTTP headers.
--- @return table; table containing the HTTP headers.
function openai.get_headers()
  return {
    ["Content-Type"] = "application/json",
    ["Authorization"] =
        "Bearer " .. openai.key
  }
end

--- @param data string
--- @param _context Context
--- @return { model: string, messages: message[] }
function openai.get_payload(data, _context)
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

--- @param payload table; body of the request
--- @param ctx Context; contexto
function openai.send(payload, ctx)
  require("plenary.curl").post("https://api.openai.com/v1/chat/completions", {
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

function openai.setup(opts)
  openai.key = opts.key;
end

return openai
