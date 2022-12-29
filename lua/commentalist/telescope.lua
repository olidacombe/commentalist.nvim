local pickers = require("telescope.pickers")
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local commentalist = require("commentalist")

local M = {}

M.fonts = function(opts)
    local buf = assert(opts.bufnr, "opts.bufnr must be specified")
    local line1 = assert(opts.line1, "opts.line1 must be specified")
    local line2 = assert(opts.line2, "opts.line2 must be specified")

    -- nvi_buf_get_lines Indexing is __zero-based__, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)

    -- preserve file type for comment specifics
    local filetype = opts.filetype or vim.bo.filetype

    pickers.new(opts, {
        prompt_title = "fonts",
        finder = finders.new_table {
            results = commentalist.renderers.figlet,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- TODO not be so wasteful as to call the renderen again
                -- (and previewer caching while we're at it)
                -- set the chosen font in options
                opts.fargs = { selection[1] }
                -- commit the selected comment
                commentalist.comment(opts)
            end)
            return true
        end,
        previewer = previewers.new_buffer_previewer({
            title = "Preview",
            define_preview = function(self, entry, status)
                -- TODO really this condition?
                if entry then
                    local bufnr = self.state.bufnr
                    local font = entry[1]
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.bo.filetype = filetype
                    end)
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
                    commentalist.comment({
                        bufnr = bufnr,
                        line1 = 1,
                        line2 = #lines,
                        fargs = { font }
                    })
                end
            end
        }),
    }):find()
end

return M
