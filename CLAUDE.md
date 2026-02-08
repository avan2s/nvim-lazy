# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Overview

This is a **LazyVim-based Neovim configuration** written in Lua, focused on TypeScript/JavaScript development with extensive debugging (DAP) capabilities. It extends [LazyVim](https://lazyvim.github.io/) rather than replacing it—LazyVim provides the base config, and custom files override or extend behavior.

## Architecture

### Entry Point & Bootstrap

`init.lua` → `lua/config/lazy.lua` → bootstraps lazy.nvim → loads LazyVim base + `lua/plugins/*.lua`

### Directory Layout

- `lua/config/` — Core config loaded by LazyVim automatically:
  - `lazy.lua` — lazy.nvim setup, plugin spec imports
  - `options.lua` — Vim options (2-space tabs, relative numbers, format-on-save disabled, macro key `q` disabled)
  - `keymaps.lua` — Global keybindings
  - `autocmds.lua` — Autocommands (minimal, relies on LazyVim defaults)
- `lua/plugins/` — Plugin specifications (one file per plugin/concern)
- `lua/user/` — Custom utility modules (DAP helpers, launch.json loader, auto-attach)
- `lazyvim.json` — Tracks enabled LazyVim extras (20+ extras including dap.core, prettier, eslint, language support)

### Plugin Organization Pattern

Files follow a naming convention:

- **`extend-*.lua`** — Override/extend a LazyVim-provided plugin (e.g., `extend-lsp.lua`, `extend-gitsigns.lua`, `extend-mini-files.lua`)
- **`*.lua`** (no prefix) — Add new plugins not in LazyVim (e.g., `diffview.lua`, `vim-tmux-navigator.lua`)
- **`disabled.lua`** — Centralized place to disable plugins (currently all commented out)

Plugins are disabled mid-development with `if true then return {} end` at the top of their file.

### Key Design Decisions

- **Format on save is OFF** (`vim.g.format_on_save = false`) — formatting is manual
- **Clipboard-preserving keymaps** — `x`, `c`, `C`, `<leader>d` all use the black-hole register to avoid overwriting the clipboard
- **`H`/`L` remapped** to beginning/end of line; `<M-h>`/`<M-l>` for buffer navigation
- **Snacks.nvim picker** replaces `<leader>e`/`<leader>E` (those are freed for mini.files); custom symbol pickers on `<leader>oo`, `<leader>om`, `<leader>fi`
- **Tmux integration** via vim-tmux-navigator (`<C-h/j/k/l>` for pane navigation)

### DAP (Debugging) Subsystem

The most complex custom code lives in `lua/user/`:

- `load_launch_json.lua` — Loads `.vscode/launch.json`, maps types to filetypes, applies overrides
- `js_debug_adapter.lua` — Custom "node-terminal" adapter using toggleterm
- `dap_prelaunch.lua` — Runs npm scripts as pre/post-debug tasks, Vitest integration
- `auto_node_attach/init.lua` — Auto-attaches debugger when "Debugger listening" appears in terminal

Note: Both `dap.lua` and `dap-ui.lua` are currently disabled (`if true then return {} end`). The active DAP config is in `extend-dap.lua`.

### LazyVim Extras Enabled

Languages: docker, json, markdown, prisma, python, sql, toml, vue, yaml
Coding: mini-surround (prefix `gs`), yanky
Editor: harpoon2, inc-rename, mini-files
Formatting: prettier | Linting: eslint | Testing: neotest

## Working With This Config

All configuration is Lua. When adding a new plugin, create a new file in `lua/plugins/`. When extending a LazyVim plugin, use the `extend-*.lua` naming convention and return a table with the plugin's GitHub path as the first element.

Mini.surround uses `gs` prefix (not the default `sa`). See README.md for examples.
