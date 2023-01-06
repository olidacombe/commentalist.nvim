# Commentalist

This plugin aims to trivialize the making of bombastic ascii comments.

![Preview](https://user-images.githubusercontent.com/1752435/209985337-77a085de-e0d6-43ce-bd87-8bff2f4ca0ae.gif)

Currently supporting the following engines:

+ boxes
+ cowsay
+ figlet

## Dependencies

+ [Comment.nvim](https://github.com/numToStr/Comment.nvim)
+ [telescope](https://github.com/nvim-telescope/telescope.nvim)
+ boxes (optional)
+ cowsay (optional)
+ figlet (optional)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    'olidacombe/commentalist.nvim',
    requires = {
        { 'nvim-telescope/telescope.nvim' },
        { 'numToStr/Comment.nvim' },
    }
}
```

## Setup

Call the setup funtion somewhere in your configs

```lua
require("commentalist").setup()

-- optionally add a keymap
vim.keymap.set({ "n", "v" }, "<leader>mm", ":Commentalist<CR>")
```

### Custom Renderers

To define your own renderers, you can pass them to `setup()` under the `renderers` key.

```lua
require("commentalist").setup({
    renderers = {
        my_custom = {
            -- a renderer with no fonts
            render = function(lines, _)
                table.insert(lines, 1, "[com]")
                table.insert(lines, "[ment]")
                return lines
            end,
        },
        my_other = {
            -- a renderer which takes "fonts"
            -- you must specify which fonts to offer
            render = function(lines, font)
                table.insert(lines, 1, "[com:" .. font "]"
                table.insert(lines, "[ment:" .. font "]"
                return lines
            end,
            fonts = function(register)
                register("a font")
                register({ "some", "other", "fonts" })
            end,
            -- alt: pass a static table of fonts
            -- fonts = {"greasy", "oily"},
        }
    }
})
```

Your `render` function takes as arguments:

1. `lines` - a table of strings, each containing no newlines.
2. `font` (optional) - a string indicating which `font` the user has chosen.

And it must return either:

- a table of strings, each containing no newlines
- a _started_ [plenary.job](https://github.com/nvim-lua/plenary.nvim/blob/master/lua/plenary/job.lua) which will return such a table of strings

## checkhealth

TODO

# Usage

Use the command `:Commentalist` to bring up a telescope previewer allowing
you to browse the output you can expect.

Or if you already know which `{renderer}/{font}` you want to apply to a range, call with
the font as an argument, `:Commentalist {renderer}/{font}`.
