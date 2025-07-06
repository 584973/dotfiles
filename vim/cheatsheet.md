# 📄 Netrw Cheatsheet – File Navigation & Management in Vim

## 🔍 Opening Netrw

| Command          | Action                                      |
|------------------|---------------------------------------------|
| `:Ex`            | Open netrw in current directory             |
| `:Sex` / `:Vex`  | Open in horizontal/vertical split           |
| `:Explore [dir]` | Open netrw at specific path                 |

---

## 🧭 Navigation

| Key     | Action                            |
|---------|-----------------------------------|
| `Enter` | Open file or enter directory      |
| `-`     | Go up one directory               |
| `~`     | Go to home directory              |
| `P`     | Go to previously visited dir      |
| `gh`    | Toggle hidden files               |
| `i`     | Cycle view style (thin, long, wide, tree) |
| `s`     | Toggle sorting                    |

---

## 🛠 File Operations

| Key   | Action                         |
|-------|--------------------------------|
| `%`   | Create a new file              |
| `d`   | Create a new directory         |
| `D`   | Delete file or directory       |
| `R`   | Rename file or directory       |

---

## 📋 Marking Files

| Key     | Action                            |
|---------|-----------------------------------|
| `mf`    | Mark file                         |
| `mu`    | Unmark file                       |
| `mF`    | Unmark all files                  |
| `:NetrwMarkFileList` | List all marked files       |
| `mc`    | Copy marked files                 |
| `mm`    | Move marked files                 |
| `md`    | Delete marked files               |
| `mp`    | Paste marked files here           |

> 🔔 **Marked files** show up with a `>` in front of the file name.

---

## 🔧 Optional Configuration (`.vimrc`)

```vim
let g:netrw_banner = 0          " Disable top banner
let g:netrw_liststyle = 3       " Tree-style view
let g:netrw_browse_split = 4    " Open files in previous window
let g:netrw_altv = 1            " Vertical splits to the right
let g:netrw_winsize = 25        " Split size
