return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require('gitsigns').setup({
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']h', gs.next_hunk)
        map('n', '[h', gs.prev_hunk)
        map('n', '<leader>hs', gs.stage_hunk)
        map('n', '<leader>hr', gs.reset_hunk)
        map('n', '<leader>hb', function() gs.blame_line{full=true} end)
      end
    })
  end
}
