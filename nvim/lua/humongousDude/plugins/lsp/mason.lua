return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        mason.setup()

        mason_lspconfig.setup({
            ensure_installed = {
                "clangd",
                "rust_analyzer",
            },
            automatic_installation = true,
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "clangd",
                "clang-format",
                "rust-analyzer",
            },
        })

        -- Shared settings
        local capabilities = cmp_nvim_lsp.default_capabilities()

        local on_attach = function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
        end

        -- Modern LSP configuration API
        vim.lsp.config["clangd"] = {
            cmd = {
                "clangd",
                "--clang-tidy",
                "--completion-style=detailed",
                "--header-insertion=never",
                "--inlay-hints", -- enable parameter/variable hints
            },
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git" },
            capabilities = capabilities,
            on_attach = on_attach,
        }

        -- Optional: configure others too (example)
        vim.lsp.config["rust_analyzer"] = {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end,
}
