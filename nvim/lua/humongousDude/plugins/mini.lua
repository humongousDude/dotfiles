return {
    'echasnovski/mini.nvim',
    version = false,

    config = function()
        require('mini.cursorword').setup()
        require('mini.starter').setup()
        require('mini.statusline').setup()
        -- require('mini.tabline').setup()
        require('mini.trailspace').setup()
        require('mini.hipatterns').setup()
        require('mini.indentscope').setup()

        require('mini.basics').setup()
        require('mini.bracketed').setup()
        require('mini.bufremove').setup()
        require('mini.icons').setup()
        require('mini.clue').setup()
        require('mini.deps').setup()
        require('mini.extra').setup()
        require('mini.files').setup()

        require('mini.operators').setup()
        -- require('mini.surround').setup()
        require('mini.comment').setup()
        -- require('mini.snippets').setup()
        -- require('mini.completion').setup({
        --     delay = { completion = 0, info = 0, signature = 0 },
        -- })
        require('mini.keymap').setup()
        require('mini.move').setup()
        require('mini.pairs').setup()
        require('mini.splitjoin').setup()
        require('mini.align').setup()

        require('mini.fuzzy').setup()

        vim.keymap.set('n', '<C-n>', function()
            require("mini.files").open()
        end)
    end
}
