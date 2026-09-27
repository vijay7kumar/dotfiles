return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { silent = true, noremap = true })
  end
}
