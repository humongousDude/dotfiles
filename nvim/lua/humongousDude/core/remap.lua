local keymap = vim.keymap


vim.g.mapleader = " "

keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>")
keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>")

keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-l>", "<C-w>l")
keymap.set("n", "<C-k>", "<C-w>k")

keymap.set("x", "<leader>p", [["_dP]])

keymap.set({ "n", "v" }, "<leader>d", [["_d]])

keymap.set("n", "<leader>f", vim.lsp.buf.format)

keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
