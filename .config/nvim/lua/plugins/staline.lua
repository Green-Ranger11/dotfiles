return {
  {
    "tamton-aquib/staline.nvim",
    config = function()
      require("staline").setup({
        sections = {
          left = {
            "- ",
            "-mode",
            "left_sep_double",
            "file_name",
            "  ",
            "branch",
          },
          mid = { "lsp" },
          right = {
            "cool_symbol",
            "|  ",
            vim.bo.fileencoding:upper(),
            "right_sep_double",
            "-line_column",
          },
        },
        defaults = {
          cool_symbol = "  ",
          left_separator = "",
          right_separator = "",
          full_path = false,
          branch_symbol = " ",
        },
      })
    end,
  },
}
