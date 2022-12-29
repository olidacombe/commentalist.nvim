# Commentalist

This plugin aims to trivialize the making of bombastic ascii comments.

![Preview](https://user-images.githubusercontent.com/1752435/209985337-77a085de-e0d6-43ce-bd87-8bff2f4ca0ae.gif)

Currently supporting the following engines:

+ figlet

## Dependencies

+ figlet
+ [telescope](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    'olidacombe/commentalist.nvim',
    requires = { { 'nvim-telescope/telescope.nvim' } }
}
```

I may soon make `telescope` optional, but this plugin is significantly
less worth using without it.

## Setup

Call the setup funtion somewhere in your configs

```lua
require("commentalist").setup

-- optionally add a keymap
vim.keymap.set({ "n", "v" }, "<leader>mm", ":Commentalist<CR>")
```

## checkhealth

TODO

# Usage

Use the command `:Commentalist` to bring up a telescope previewer allowing
you to browse the output you can expect.

Or if you already know which font you want to apply to a range, call with
the font as an argument, `:Commentalist {font}`.
