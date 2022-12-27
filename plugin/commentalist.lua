local commentalist = require("commentalist")

vim.api.nvim_create_user_command("Commentalist", function(font)
    commentalist.comment(font)
end, {
    nargs = "?", -- specify a renderer (e.g. `figlet/block`),
    -- or user a default / display a picker
    range = 1, -- range allowed, default to current line
})
