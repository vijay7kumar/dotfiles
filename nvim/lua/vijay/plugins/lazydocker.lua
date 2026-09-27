return {
  dir = vim.fn.stdpath("config") .. "/lua/vijay/plugins",
  name = "lazydocker-custom",
  virtual = true,
  config = function()
    local function open_lazydocker()
      local buf = vim.api.nvim_create_buf(false, true)
      local width = math.floor(vim.o.columns * 0.9)
      local height = math.floor(vim.o.lines * 0.9)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
      })

      vim.fn.termopen("lazydocker")
      vim.cmd("startinsert")

      vim.keymap.set("t", "<Esc>", "<C-\\><C-n><cmd>q<cr>", { buffer = buf })
      vim.keymap.set("t", "q", "<cmd>q<cr>", { buffer = buf })
    end

    vim.keymap.set("n", "<leader>gd", open_lazydocker, { silent = true, noremap = true })
  end
}
