source ~/.vimrc.bundles
source ~/.vimrc.global
source ~/.vimrc.plugins
source ~/.vimrc.macros

" Save on focus
au FocusLost * :wa

" Folding for vim-javascript
au FileType javascript call JavaScriptFold()

" autocmd BufRead,BufWritePre *.html normal gg=G
autocmd BufNewFile,BufRead *.html setlocal nowrap
au BufNewFile,BufReadPost *.html setl shiftwidth=2 tabstop=2 softtabstop=2 expandtab
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 softtabstop=2
au BufNewFile,BufRead *.hbs set ft=html

augroup html_files "{{{
  au!
augroup END

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

autocmd BufWritePre * :%s/\s\+$//e

" Get snipmate's css snippets to work with scss files
au BufNewFile,BufRead *.scss set ft=scss.css
set omnifunc=csscomplete#CompleteCSS

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

" Powerline Installation
set rtp+={/Users/andrewsolomon/powerline-fonts/}/powerline/bindings/vim
