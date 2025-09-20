return {
  "nvim-mini/mini.operators",
  version = "*",
  opts = {
    evaluate = nil,
    exchange = nil,
    multiply = nil,
    sort = nil,
    { "gshl", false },
    { "gshn", false },
    { "gsh", false },
    { "gfsl", false },
    { "gwsfn", false },
    { "gsf", false },
    { "gsFl", false },
    { "gsFn", false },
    { "gsF", false },
    replace = {
      prefix = "gp",
      -- Whether to reindent new text to match previous indent
      reindent_linewise = true,
    },
  },
}
