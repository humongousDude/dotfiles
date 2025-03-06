return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        -- import mason
        local mason = require("mason")

        -- import mason-lspconfig
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        mason.setup()

        mason_lspconfig.setup({
            --list of servers for mason to install
            ensure_installed = {
                "rust_analyzer",
            },

            automatic_installation = true,
        })

        mason_lspconfig.setup_handlers({
            -- The first entry (without a key) will be the default handler
            -- and will be called for each installed server that doesn't have
            -- a dedicated handler.
            function(server_name) -- default handler (optional)
                if server_name == "rust_analyzer" then
                    goto continue
                end

                require("lspconfig")[server_name].setup({})
                ::continue::
            end,
        })
    end,
}
