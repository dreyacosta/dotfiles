" Set syntax highlighting options
set t_Co=256
set background=dark
syntax on
colorscheme jellybeans

" Change mapleader
let mapleader=","

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on

set encoding=utf-8 nobomb
set timeoutlen=1000 ttimeoutlen=0 " Eliminating delays on ESC in vim
set clipboard=unnamed             " Accessing the system clipboard
set ignorecase                    " Searching is not case sensitive
set nowrap                        " Stop line breaking
set cursorline                    " Highlight current line
set title                         " Automatically set screen title
set number                        " Display line numbers
set splitright                    " Open new split panes to right
set wildmode=list:longest,full    " Do completion in the command line via tab
set wildchar=<TAB>
set wildignore=node_modules/**/*  " Not search through hidden files and folders
set backspace=2                   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile                    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50                    " Command history
set ruler                         " show the cursor position all the time
set showcmd                       " display incomplete commands
set hlsearch                      " Higlight on searching
set incsearch                     " do incremental searching
set laststatus=2                  " Always display the status line
set autowrite                     " Automatically :write before running commands

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
augroup END

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Go to the beginning of the first word instead of the line
map 0 ^

nnoremap ´ :
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

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
map <C-J> <C-w>j
map <C-K> <C-w>k
map <C-H> <C-w>h
map <C-L> <C-w>w

map <C-B> <esc>:CtrlPBuffer<cr>

" Increment / decrement vertical split size
map ++ :vertical resize +5<cr>
map -- :vertical resize -5<cr>

" Copy to the system clipboard
vmap <C-c> :w !pbcopy<CR><CR>

" NERDTree toggle
map <C-n> :NERDTreeToggle<CR>

" Plugin stuffs
" let g:ctrlp_custom_ignore = { 'dir':  '\v[\/]\.(git|hg|svn)|node_modules$' }
" let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
let g:syntastic_javascript_checkers=['eslint']
" let g:loaded_syntastic_javascript_eslint_checker = 1
"let g:netrw_liststyle = 3
let g:airline_powerline_fonts = 1

autocmd BufWritePre * :%s/\s\+$//e
autocmd VimResized * :wincmd =
