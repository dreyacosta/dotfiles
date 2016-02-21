" Make vim more useful
set nocompatible
filetype off

" Set syntax highlighting options
set t_Co=256
set background=dark
syntax on
colorscheme jellybeans

" Change mapleader
let mapleader=","

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Plugin 'Shutnik/jshint2.vim'
Plugin 'wookiehangover/jshint.vim'
Plugin 'scrooloose/syntastic'
Plugin 'FelikZ/ctrlp-py-matcher'
Plugin 'kien/ctrlp.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'msanders/snipmate.vim'
Plugin 'fatih/vim-go'
" Plugin 'tpope/vim-surround'
" Plugin 'airblade/vim-gitgutter'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on

" Some settings
set clipboard=unnamed
set backspace=indent,eol,start
set cursorline
set encoding=utf-8 nobomb
set hidden
set history=1000
set hlsearch
set incsearch
set laststatus=2
set ignorecase
set nowrap
set expandtab
set shiftwidth=2
set softtabstop=2
set showtabline=2
set splitright
set title
set wildchar=<TAB>
set wildmode=list:longest
set wildignore=node_modules/**/*
set ruler
set relativenumber
set timeoutlen=1000 ttimeoutlen=0

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Go to the beginning of the first word instead of the line
map 0 ^

" Edition maps
imap <leader>a <esc>0i
imap <leader>e <esc>$i
imap <leader>s <esc>:w<cr>i
imap <leader>d <esc>ddi
imap <leader>u <esc>ui

" Split maps
nmap <leader>vs :vs <C-r>=escape(expand("%:p:h"), ' ') . '/'<cr>
imap <leader>vs <esc>:vs <C-r>=escape(expand("%:p:h"), ' ') . '/'<cr>

" Quicker window movement
map <leader>j <C-w>j
map <leader>k <C-w>k
map <leader>h <C-w>h
map <leader>l <C-w>l

vmap <C-c> :w !pbcopy<CR><CR>

" Plugin stuffs
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)|node_modules$'
  \ }

let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
let g:syntastic_javascript_checkers=['jscs']

autocmd VimResized * :wincmd =
