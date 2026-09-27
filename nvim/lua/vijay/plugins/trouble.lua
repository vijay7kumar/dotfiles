return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  config = function()
    require("trouble").setup({})
    vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>")
    vim.keymap.set("n", "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>")
    vim.keymap.set("n", "<leader>tw", "<cmd>Trouble diagnostics toggle<cr>")
  end
}
