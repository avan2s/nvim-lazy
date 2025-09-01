-- https://tsx.is/vscode
return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<F8>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>dn",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<F7>",
      function()
        require("dap").step_into()
      end,
      desc = "Step into",
    },
    -- does not work yet
    {
      "<S-F7>",
      function()
        require("dap").step_out()
      end,
      desc = "Step out",
    },

    {
      "<F9>",
      function()
        require("dap").continue()
      end,
      desc = "Run/Continue",
    },
  },
}
