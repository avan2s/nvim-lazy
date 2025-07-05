# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation]"(<https://lazyvim.github.io/installation>) to get started.

## Mini surround

Mini surround has some keybindings you do directly don't know or forget:
Reminder `gs` is your prefix related to everything surround mechanism.
Nevertheless mini surround can also do more:

Examples:
`gsaiw"` - (a)dd (i)nside (w)ord " -> will surround the current word with "
`gsai({` - will surround everything inside `(`
`gsaiwt` - surround with a tag you can specify
`gsr"'` - replace double quotes with single quotes

Or go to visual mode and select whatever you want and do:
`gsat` - surround with a tag .
`gsa"` - surround with a "

With my adjusted configuration you can also press `S` instead of `gsa` when you
have something selected in visual mode.
