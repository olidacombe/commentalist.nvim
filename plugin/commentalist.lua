local commentalist = require "commentalist"

vim.api.nvim_create_user_command("Commentalist", function(opts)
    opts["bufnr"] = vim.api.nvim_get_current_buf()
    commentalist.comment(opts)
end, {
    nargs = "?", -- specify a renderer (e.g. `figlet/block`),
    -- or user a default / display a picker
    range = 1, -- range allowed, default to current line
})
