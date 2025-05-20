return {
    "hrsh7th/nvim-cmp",
    event = "BufReadPost",
    dependencies = {
        "hrsh7th/cmp-buffer",           -- source for text in buffers
        "hrsh7th/cmp-path",             -- source for file system paths
        "onsails/lspkind.nvim",
        "L3MON4D3/LuaSnip",             -- snippet engine
        "saadparwaiz1/cmp_luasnip",     -- for autocompletion
        "rafamadriz/friendly-snippets", -- useful snippets
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- load vs-code like snippets from plugins (e.g. friendly snippets)
        require("luasnip.loaders.from_vscode").lazy_load()

        vim.opt.completeopt = "menu,menuone,noselect"
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered({
                    scrollbar = false,
                }),
                documentation = cmp.config.window.bordered({
                    winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
                    scrollbar = false,
                    side_padding = 0,
                    col_offset = 0,
                }),
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                --["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<Tab>"] = cmp.mapping.confirm({ select = false }),
            }),
            -- sources for autocompletetion
            sources = cmp.config.sources({
                { name = "nvim_lsp" }, -- lsp
                { name = "luasnip" },  -- snippets
                { name = "path" },     -- system file paths
                { name = "glsl_analyzer" },
            }),
            -- configure lspkind for vs-code like icons
            formatting = {
                format = lspkind.cmp_format({
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
            },
        })
    end,
}
