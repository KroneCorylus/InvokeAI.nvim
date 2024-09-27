# InvokeAI.nvim
On-demand AI integration for Neovim. Send, replace, and prompt code with ease.


## Setup

### Install

##### Lazy.nvim
```lua
{
  "KroneCorylus/InvokeAI.nvim",
  opts = {
    ---Your configuration options here.
  },
}
```

### Configuration

| Key      | Type                 | Default              | Description   
| -        | -                    | -                    | -       
| key      | string               | nil                  | Your API Key             
| key_fn   | fun():string         | nil                  | A function that returns your API Key


### Keymaps and usage examples

```lua
-- Manual prompt examples
vim.keymap.set('v', '<Leader>ip', require('invokeai').popup, { desc = "Ask AI and get response in floating window" })

vim.keymap.set('v', '<Leader>ir', function()
  require('invokeai').popup({ resolve_fn = require("invokeai.resolvers.replace") })
end, { desc = "Ask AI and replace selected text with response" })

-- Predefined prompt examples
vim.keymap.set('v', '<Leader>it', function()
  require('invokeai').pre_prompt(
    "Add the correct type annotations",
    { resolve_fn = require("invokeai.resolvers.replace") })
end, { desc = "Ask for type annotations and replace selected text with response" })

```
