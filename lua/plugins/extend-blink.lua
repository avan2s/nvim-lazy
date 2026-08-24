--[[
  Class decorators (`@Injectable`) got no completion, while parameter decorators did.

  For a bare `@` in front of a class, tsserver only answers with member modifier
  keywords (abstract, public, static, …) and marks the response complete
  (isIncomplete = false). blink.cmp then caches it and just filters that list
  client-side for every following keystroke, so `@Inje` never re-queries the
  server and the decorator (plus its auto-import) never appears. Inside a
  constructor tsserver marks the same request incomplete, which is why it works
  there.

  Blocking `@` as a trigger character skips that first useless request, so the
  menu opens on `@I` with a fresh query returning the full identifier list.
  Trade-off: in JSDoc the tag list appears from `@p` instead of `@`.
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
