# wezterm-conf

My [WezTerm](https://wezterm.org/) configuration, kept in its own repo so it's easy to set up on any machine — Windows, Linux, or macOS. Split out of my [dotfiles](https://github.com/brett-fisher-research/dotfiles) for better cross-platform ergonomics.

## What's in the config

The centerpiece is a **tmux emulation layer**: `Ctrl+b` acts as a leader key (like the tmux prefix), workspaces stand in for sessions, and tabs stand in for windows. If you have tmux muscle memory, it mostly just works:

| Keys | Action |
| --- | --- |
| `Ctrl+b c` / `n` / `p` / `1-9` / `,` | New tab, next/prev tab, jump to tab, rename tab |
| `Ctrl+b "` / `%` | Split pane down / right (in the current pane's directory) |
| `Ctrl+b h j k l` | Navigate panes (vim-style) |
| `Ctrl+b H J K L` | Resize panes |
| `Ctrl+b z` / `x` / `o` | Zoom pane, kill pane, cycle panes |
| `Ctrl+b [` | Copy mode (vi keys: `v` select, `y` yank) |
| `Ctrl+b ]` | Paste |
| `Ctrl+b s` / `S` / `$` | Pick session (workspace), new named session, rename session |
| `Ctrl+b w` | Fuzzy tab picker |
| `Ctrl+b r` | Reload config |
| `Ctrl+b Ctrl+b` | Send a literal `Ctrl+b` to the shell |

The leader waits 1.5 seconds for the next key. Other settings:

- **Windows only:** Git Bash as the default shell; `Shift+Enter` inserts a newline (useful for Claude Code and other multi-line prompts)
- Tokyo Night color scheme

## Setup on a new machine

### 1. Install prerequisites

- [WezTerm](https://wezterm.org/installation.html) — `winget install wez.wezterm` on Windows, `brew install --cask wezterm` on macOS, packages available for every major Linux distro
- [Node.js](https://nodejs.org/) — only used to run the setup script

### 2. Clone and run setup

```sh
git clone https://github.com/brett-fisher-research/wezterm-conf.git
cd wezterm-conf
npm run setup
```

The setup script is **idempotent** — run it as many times as you like (e.g. after pulling config changes). It copies `wezterm.lua` to `~/.wezterm.lua`, which WezTerm reads on every platform. Open WezTerm windows pick up the change automatically; there is nothing to restart.

## Making changes

Edit `wezterm.lua` in this repo, then re-run `npm run setup` to apply it. This keeps the repo as the single source of truth instead of editing `~/.wezterm.lua` directly.
