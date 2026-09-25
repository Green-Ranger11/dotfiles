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
        -- Normal mode badge uses the desktop accent (green); the other modes
        -- keep staline's syntax-derived colours.
        mode_colors = { n = "#a6e3a1" },
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
