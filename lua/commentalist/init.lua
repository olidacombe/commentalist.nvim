local comment_api = require("Comment.api")
local fonts = require("commentalist.fonts")
local renderers = require("commentalist.renderers")
local figlet = require("commentalist.renderers.figlet")

local M = {}

M.defaults = {
    renderers = {
        -- blocky = {
        --     render = function(lines, _)
        --         return lines
        --     end
        --     -- fonts = function({register callback}) -> nil | table | nil
        -- },
        figlet = figlet
    }
}

M.setup = function(opts)
    opts = opts or {}
    -- TODO condition default renderers on check for binaries
    -- e.g. if `figlet` or `figlist` aren't in the path then
    -- don't add a figlet renderer
    local settings = M.defaults

    for renderer, renderer_opts in pairs(opts.renderers or {}) do
        settings.renderers[renderer] = renderer_opts
    end

    for renderer, opts in pairs(settings.renderers or {}) do
        local render = assert(opts.render, "no render funtion specified for renderer `" .. renderer .. "`")
        renderers.register(renderer, render)
        fonts.register(renderer, opts.fonts)
    end
end

local cursor_stack = function(buf, line, col, callback)
    local win = 0
    local orig_buf = vim.api.nvim_get_current_buf()
    local orig_cursor = vim.api.nvim_win_get_cursor(win)

    if buf then
        vim.api.nvim_win_set_buf(win, buf)
    end
    vim.api.nvim_win_set_cursor(win, { line, col })

    callback()

    vim.api.nvim_win_set_cursor(win, orig_cursor)
    vim.api.nvim_win_set_buf(win, orig_buf)
end

local uncomment = function(line1, line2)
    cursor_stack(nil, line1, 0, function()
        -- TODO just uncomment either type, and not error
        -- when an uncomment fails (because it wasn't a comment
        -- or a particular type of comment
        comment_api.uncomment.linewise.count(line2 - line1 + 1)
    end)
end

local comment = function(line1, line2)
    cursor_stack(nil, line1, 0, function()
        comment_api.comment.linewise.count(line2 - line1 + 1)
    end)
end

M.comment = function(opts)
    opts = opts or {}
    -- get variables
    opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
    local fargs = opts.fargs or {}
    local font = fargs[1]
    opts.line1 = opts.line1 or 1
    opts.line2 = opts.line2 or -1
    -- if no font has been sepecified, let the user select one
    if not font then
        -- TODO picker comes from config created at setup,
        -- and may not be telescope
        require("commentalist.telescope").fonts(opts)
        return
    end
    -- Otherwise we've been ginen a font, act

    local bufnr, line1, line2 = opts.bufnr, opts.line1, opts.line2

    -- Strip comments first
    vim.api.nvim_buf_call(bufnr, function()
        uncomment(line1, line2)
    end)

    -- nvim_buf_get_lines Indexing is zero-based, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
    lines = table.concat(lines, "\n")

    local ascii_render = renderers.get(font)(lines)

    -- TODO only do this async stuff for a plenary.job
    -- otherwise, use a sync result for ascii var
    ascii_render:sync()
    local ascii = ascii_render:result()

    vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, ascii)
    -- TODO a more robust count of the output lines
    vim.api.nvim_buf_call(bufnr, function()
        comment(line1, line1 + #ascii - 1)
    end)
end

return M
