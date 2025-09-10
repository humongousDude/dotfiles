local keymap = vim.keymap


vim.g.mapleader = " "

keymap.set("i", "<C-j>", "<Down>")
keymap.set("i", "<C-k>", "<Up>")
keymap.set("i", "<C-h>", "<Left>")
keymap.set("i", "<C-l>", "<Right>")

keymap.set("i", "hj", "<Esc>")

keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>zz")
keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>zz")
keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>zz")

keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>")
keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>")

keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-l>", "<C-w>l")
keymap.set("n", "<C-k>", "<C-w>k")

-- keymap.set("n", "<Tab>", "<cmd>bnext<CR>zz")
-- keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>zz")
-- keymap.set("n", "<leader>x", "<cmd>bdelete<CR>zz")

keymap.set("n", "J", "mzJ`z")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])


keymap.set({ "n", "v" }, "<leader>d", [["_d]])

keymap.set("n", "<leader>f", vim.lsp.buf.format)

keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
