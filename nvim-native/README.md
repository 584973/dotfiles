# Native Neovim experiment

A separate Neovim 0.12+ configuration with **no third-party plugins**. It uses
Neovim's bundled runtime, including netrw. Your existing `nvim/` configuration is
unchanged; `NVIM_APPNAME=nvim-native` gives this experiment separate data, cache,
state, and installed-package paths.

## Try without installing

From the dotfiles repository root:

```sh
NVIM_APPNAME=nvim-native nvim \
  --cmd "set runtimepath^=$PWD/nvim-native/.config/nvim-native" \
  -u "$PWD/nvim-native/.config/nvim-native/init.lua"
```

This leaves `XDG_CONFIG_HOME` unchanged for child programs. For regular use,
install the separate module instead:

```sh
stow -nvt ~ nvim-native
stow -vt ~ nvim-native
NVIM_APPNAME=nvim-native nvim
```

Plain `nvim` still uses your original configuration. Undo the separate install
with `stow -D nvim-native`.

## Code organization

`init.lua` loads feature-focused modules directly from `lua/`:

- `options.lua`: general editor settings.
- `editing.lua`: pairs, clipboard, line movement, and yank highlighting.
- `colorscheme.lua`: Catppuccin and transparency.
- `buffers.lua`: buffer mappings and the buffer tabline.
- `statusline.lua`: global statusline.
- `explorer.lua`: netrw settings and directory browsing.
- `search.lua`: file finding, text search, recent files, help, and marks.
- `dashboard.lua`: start screen with recent files and create/find actions.
- `terminal.lua`: floating shell.
- `tmux-nav.lua`: split and tmux pane navigation.

There is no separate `custom/` directory.

## What's kept

- Existing indentation, relative numbers, cursor line, whitespace markers,
  persistent undo, simple pair insertion, clipboard mappings, and line movement.
- `Space n` / `Space p` / `Space x`: next, previous, and delete buffer.
- `Space tt`: persistent floating shell; Escape hides it.
- Ctrl-h/j/k/l: navigate splits, then tmux panes at the edges.
- Yank highlighting and a transparent terminal background.

## Start screen

Start without file arguments to see a centered dashboard in the current directory.
It shows up to five recently opened files under that directory, including subdirectories.
Use `j` / `k` or the arrow keys to select a file or action, then press Enter.
The `1`–`5` shortcuts open files directly; `n` prompts for a new filename and `f`
starts native `:find` completion. Type a query, then press Tab to see matches.
Press `q` or select Quit to exit Neovim without discarding unsaved changes.
The screen uses the configured Catppuccin colors and adds no plugins.

File arguments, piped input, and existing buffer content are left unchanged.
The native config has its own recent-file history, separate from plain `nvim`.

## Native replacements

| Key / feature | Replacement |
| --- | --- |
| `e` | netrw parent-directory browser, with hidden files visible |
| `Space ff` | `:find` with native fuzzy matching; type a query, then Tab |
| `Space fr` | `:browse oldfiles`; choose a file number |
| `Space fg` | Vim-regex search across files into quickfix |
| `Space fb` | `:buffer`; type a query, then Tab for fuzzy completion |
| `Space fh` | `:help`; type a topic, then Tab for completion |
| `Space fm` | `:marks`; jump with `'a` or `` `a `` afterwards |
| Bufferline / lualine | Buffer labels in `tabline` and a built-in global statusline |
| Tokyo Night | Bundled `catppuccin` colorscheme |

Use Tab / Shift-Tab or Ctrl-n / Ctrl-p in completion menus. In quickfix, Enter
opens a result; `:cnext`, `:cprev`, and `:cclose` navigate or close the list.
In netrw, Enter opens an entry, `-` goes up, `%` creates a file, `d` creates a
directory, `R` renames, and `D` deletes (see `:help netrw-quickmap`).
Use `o` to open a file in a split below, or `v` to open it in a split to the right.
The explorer shows a custom, theme-colored command guide above the file list,
including create, rename, delete, split, and hidden-file commands. The guide is
not selectable and does not change netrw's file entries. Press `F1` for full help.

## Deliberate differences

- Language tooling uses installed external programs, but no third-party Neovim
  plugins. Neovim's ordinary built-in syntax and editing commands remain available.
- Search is rooted at the current working directory (`:pwd`), not an inferred
  project root. File matching and text search skip `.git`, `node_modules`, and
  `.venv` contents. File finding includes dotfiles and hidden directories;
  text search still skips them. Search does not read `.gitignore`.
- Text search runs when submitted, not live, and uses Vim regex rather than
  ripgrep syntax. It can be slower on large directory trees.
- netrw is not Oil: directory listings are not editable buffers. Recent files,
  marks, help, and buffers use native interfaces rather than floating pickers.
- The bars do not include devicons, Git branch/diff indicators, or mouse-clickable
  buffer tabs. Use the existing buffer mappings instead.
- Installed packages are excluded from `packpath`; no package manager is loaded
  and nothing is downloaded.

## Verification

From the repository root:

```sh
bash nvim-native/.config/nvim-native/tests/run.sh
```

This uses temporary XDG directories and checks startup, package isolation, fuzzy
file completion, search and ignore behavior, dashboard navigation and actions,
netrw, bar rendering, and floating terminal reuse. It does not change tmux panes.
