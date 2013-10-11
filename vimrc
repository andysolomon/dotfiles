" Leader
let mapleader = ","
set rtp+=~/dotfiles/vim/bundles/powerline/powerline/bindings/vim
set nocompatible  " Use Vim settings, rather then Vi settings
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set modelines=0
set noundofile
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85
set t_Co=256

nnoremap / /\v
nnoremap <space> /
vnoremap / /\v
nnoremap ? /\v
vnoremap ? /\v

nnoremap <C-n> :NERDTreeToggle<CR>

" strip all trailing whitespace in the current file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR> 

" reselect the text that was just pasted so I can perform commands
nnoremap <leader>v V`]
nnoremap <leader>w <C-w>v<C-w>l

" Move your splits around
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader><space> :noh<cr>
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>hbi"<esc>lel
nnoremap <leader>( viw<esc>a)<esc>hbi(<esc>lel
nnoremap H 0
nnoremap L $
inoremap jk <esc>
inoremap <esc> <nop>
onoremap p i(
onoremap in( :<c-u>normal! f(vi(<cr>
onoremap il( :<c-u>normal! F)vi(<cr>

iabbrev <buffer> --- &mdash;

" Space to toggle folds.
" nnoremap <Space> za
" vnoremap <Space> za


" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on
set smartindent


let g:Powerline_symbols = 'fancy'

au FocusLost * :wa
" Folding for vim-javascript
au FileType javascript call JavaScriptFold()

" autocmd BufRead,BufWritePre *.html normal gg=G
" autocmd BufNewFile,BufRead *.html setlocal nowrap

autocmd Filetype html nnoremap <buffer> <leader>c I<!--<esc>A--><esc>
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 softtabstop=2

augroup JavaScriptCmds
  autocmd!
  autocmd Filetype javascript nnoremap <leader>r :!node %<cr>
  autocmd Filetype javascript nnoremap <buffer> <leader>c I//<esc>
  autocmd Filetype javascript iabbrev <buffer> iff if ()<left>
  autocmd Filetype javascript setlocal tabstop=4 shiftwidth=4 softtabstop=4
augroup END

augroup vimrcEx
  autocmd!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown

  " Enable spellchecking for Markdown
  autocmd BufRead,BufNewFile *.md setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80
augroup END

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Color scheme
colorscheme github
set background=light
highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0
hi IndentGuidesOdd  ctermbg=white
hi IndentGuidesEven ctermbg=green

" Numbers
set nonumber


" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" configure syntastic syntax checking to check on open as well as save
let g:syntastic_check_on_open=1

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
