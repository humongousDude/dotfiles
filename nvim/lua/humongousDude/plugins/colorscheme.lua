return {
    "ellisonleao/gruvbox.nvim",
    dependencies = {
        "catppuccin/nvim",
        "bluz71/vim-moonfly-colors",
        "folke/tokyonight.nvim"
    },
    opts = {
    },
    name = "gruvbox",
    priority = 1000,
    config = function()
        gruvbox_transparent_bg = 1
        require("gruvbox").setup({ transparent_mode = true })
        require("tokyonight").setup({
            style = "night",
            transparent = true,
            terminal_colors = true,
        })
        vim.cmd "colorscheme tokyonight"
    end
}
-- return
-- {
--     "bluz71/vim-moonfly-colors",
--     name = "moonfly",
--     priority = 1000,
--     config = function() vim.cmd "colorscheme moonfly" end
-- }
-- return {
--     "AlphaTechnolog/pywal.nvim",
--     lazy = false, -- Load immediately on startup
--     priority = 1000, -- Ensure it loads before other colorscheme plugins
--     config = function()
--         -- Set up pywal and load the colors
--         require("pywal").setup()
--
--     end,
-- }
