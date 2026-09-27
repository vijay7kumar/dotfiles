return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
  },
  config = function()
    -- Nvim 0.12+ uses opts-based config, not the old require("nvim-treesitter.configs") API
    vim.treesitter.language.register("markdown", "mdx")

    -- Ensure parsers are installed
    local ensure_installed = {
      "lua", "vim", "vimdoc", "javascript", "typescript", "python",
      "rust", "go", "c", "cpp", "java", "html", "css", "json",
      "yaml", "toml", "bash", "markdown", "markdown_inline", "dockerfile"
    }

    -- Auto-install parsers
    for _, lang in ipairs(ensure_installed) do
      pcall(function()
        vim.treesitter.language.add(lang)
      end)
    end

    -- Run TSUpdate to install missing parsers
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local installed = {}
        for _, lang in ipairs(ensure_installed) do
          local ok = pcall(vim.treesitter.language.add, lang)
          if not ok then
            table.insert(installed, lang)
          end
        end
        if #installed > 0 then
          vim.cmd("TSInstall " .. table.concat(installed, " "))
        end
      end,
      once = true,
    })

    -- Enable treesitter highlighting and indent
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    -- Setup treesitter-context
    local ok, context = pcall(require, "treesitter-context")
    if ok then
      context.setup({
        enable = true,
        max_lines = 3,
      })
    end
  end,
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = "<C-s>",
        node_decremental = "<M-space>",
      },
    },
  },
}
