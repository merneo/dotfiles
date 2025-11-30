return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = false,
      show_end_of_buffer = false,
      integrations = {
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        treesitter = true,
        telescope = true,
      },
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.surface1 },
          CursorLineNr = { fg = colors.green, style = { "bold" } },
          WinBar = { bg = colors.base },
        }
      end,
    })
    vim.cmd.colorscheme "catppuccin"
  end,
}
