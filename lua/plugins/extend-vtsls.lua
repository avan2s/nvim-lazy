-- Tune vtsls for performance in large TypeScript/Vue files.
-- LazyVim's lang.typescript extra enables 6 inlay hint types and server-side
-- fuzzy match by default. In large files these cause constant background LSP
-- requests that compete with completion, producing the "hanging" symptom.
-- Zed uses vtsls + vue-language-server without inlay hints — match that here.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            vtsls = {
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = false,
                },
              },
            },
            typescript = {
              inlayHints = {
                enumMemberValues = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                parameterNames = { enabled = "none" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = false },
                variableTypes = { enabled = true },
              },
            },
          },
        },
      },
    },
  },
}
