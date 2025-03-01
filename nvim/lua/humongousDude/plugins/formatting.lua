return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                javascript = { "prettier" },
                json = { "prettier" },
                lua = { "stylua" },
                cpp = { "clang_format" },
                cplusplus = { "clang_format" },
                c = { "clang_format" },
                cmake = { "cmake_format" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end)

        -- local format_augroup = vim.api.nvim_create_augroup("format", { clear = true })
        -- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        -- 	group = format_augroup,
        -- 	callback = function()
        -- 		conform.format({
        -- 			lsp_fallback = true,
        -- 			async = false,
        -- 			timeout_ms = 1000,
        -- 		})
        -- 	end,
        -- })
    end,
}
