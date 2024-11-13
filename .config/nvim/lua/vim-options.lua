vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number relativenumber")
vim.opt.cursorline = true
vim.g.mapleader = " "
vim.opt.scrolloff = 8

vim.opt.conceallevel = 2

vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")

vim.keymap.set("n", "<c-k>",":wincmd k<CR>")
vim.keymap.set("n", "<c-j>",":wincmd j<CR>")
vim.keymap.set("n", "<c-h>",":wincmd h<CR>")
vim.keymap.set("n", "<c-l>",":wincmd l<CR>")

vim.cmd[[
" when not in insert mode, remap some non-US keys
map , /
" noremap M ,
map ´ \
" map ; ?

map  ¤ $
imap ¤ $
nmap ¤ $
vmap ¤ $
cmap ¤ $
xmap ¤ $
lmap ¤ $
smap ¤ $
omap ¤ $
vmap S¤ S$
nmap g¤ g$

" Use ØÆ for brackets
map  ø [
map! ø [
map  æ ]
map! æ ]
map  Ø {
map! Ø {
map  Æ }
map! Æ }
map  rø r[
map  rØ r{
map  ræ r]
map  rÆ r}
vmap Sø S[
vmap SØ S{
vmap Sæ S]
vmap SÆ S}

inoremap \ø ø
inoremap \æ æ
inoremap \å å

inoremap \Ø Ø
inoremap \Æ Æ
inoremap \Å Å

function! EnableNorway()
    " for english layout
    inoremap \[ å
    inoremap \' æ
    inoremap \; ø
    inoremap \[[ Å
    inoremap \'' Æ
    inoremap \;; Ø

    " for norwegian layout
    imap ø [
    imap æ ]
    imap Ø {
    imap Æ }

  set spelllang=en
endfunction

function! DisableNorway()
    iunmap ø
    iunmap Ø
    iunmap æ
    iunmap Æ

  set spelllang=nn
endfunction


" Toggle norwegian keys and spell language
"
" Use ToggleNorway(1) to force norwegian and
"     ToggleNorway(0) to force english.
"
function! ToggleNorway(...)
  if a:0 > 0
    let g:no_key = a:1
  else
    let g:no_key = (get(g:, 'no_key', -1) + 1) % 2
  endif
  if g:no_key == 1
    call DisableNorway()


    if !has('vim_starting')
      echomsg "language: norwegian"
    endif
  else
    call EnableNorway()

    if !has('vim_starting')
      echomsg "language: english"
    endif
  endif
endfunction

if has('vim_starting') && get(g:, 'norway_enable_at_startup', 1) == 1
  call ToggleNorway(0)
endif

augroup Norway
  au!
  au VimEnter * nnoremap <silent> yon :call ToggleNorway()<CR>
augroup end
]]
