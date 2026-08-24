--[[
  On a bare `@` before a class, tsserver answers with member modifier keywords
  (abstract, public, …) and marks the response complete, so blink keeps filtering
  that stale list instead of re-querying and `@Injectable` never shows up.
  Blocking `@` skips that first request, the menu opens on `@I` with a fresh one.
  Whitespace entries are blink's defaults, since this replaces the list.
]]
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        trigger = {
          show_on_blocked_trigger_characters = { " ", "\n", "\t", "@" },
        },
      },
    },
  },
}
