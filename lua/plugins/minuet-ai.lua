return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "InsertEnter",
    --[[
      Zed-style inline edit prediction via a self-hosted Ollama model.
      Only activate on machines that actually have Ollama installed. On a box
      without Ollama the plugin stays dormant: no ghost text, no error popups.
    ]]
    enabled = function()
      return vim.fn.executable("ollama") == 1
    end,
    opts = {
      provider = "openai_fim_compatible",
      notify = "error",
      n_completions = 1,
      context_window = 2048,
      request_timeout = 3,
      throttle = 1000,
      debounce = 400,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:7b",
          optional = {
            max_tokens = 128,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<A-A>",
          accept_line = "<A-a>",
          accept_n_lines = "<A-z>",
          prev = "<A-[>",
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },
    },
  },
}
