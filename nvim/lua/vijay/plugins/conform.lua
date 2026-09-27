return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        rust = { "rustfmt" },
        go = { "gofmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
    vim.keymap.set({"n", "v"}, "<leader>f", function()
      require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end)
  end
}
