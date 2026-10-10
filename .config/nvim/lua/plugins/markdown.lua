-- LazyVim's markdown extra runs markdownlint-cli2 on every markdown buffer.
-- Too noisy for notes/scratch files; keep marksman (links) but no style lint.
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = {}
    end,
  },
}
