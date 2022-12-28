local pickers = require("telescope.pickers")
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local commentalist = require("commentalist")

local fonts = function(opts)
    -- opts = opts or {}
    local line1, line2 = opts.line1, opts.line2

    local buf = vim.api.nvim_get_current_buf()
    -- nvi_buf_get_lines Indexing is zero-based, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)

    -- preserve file type for comment specifics
    local filetype = opts.filetype or vim.bo.filetype

    pickers.new(opts, {
        prompt_title = "fonts",
        finder = finders.new_table {
            results = { "doom", "block", "moscow", "sblood", }
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- P(selection)
                -- vim.api.nvim_put({ selection[1] }, "", false, true)
            end)
            return true
        end,
        previewer = previewers.new_buffer_previewer({
            title = "Preview dev",
            define_preview = function(self, entry, status)
                -- TODO really this condition?
                if entry then
                    local bufnr = self.state.bufnr
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.bo.filetype = filetype
                    end)
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
                    commentalist.comment({
                        bufnr = bufnr,
                        line1 = line1,
                        line2 = line2,
                        fargs = { entry[1] }
                    })
                end
            end
        }),
    }):find()
end

-- to execute the function
fonts({ line1 = -2, line2 = -1, fargs = {} })

-- some text
-- some more text
