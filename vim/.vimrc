let mapleader=" "

nnoremap <leader>e :Explore<CR>
nnoremap <leader>t :terminal<CR>
nnoremap <leader>v :Vexplore<CR>
nnoremap <leader>s :Sexplore<CR>
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>
nnoremap <leader>l :ls<CR>:b

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

set number
set relativenumber
set cursorline

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set scrolloff=8

syntax on
colorscheme default

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·
