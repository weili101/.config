" === Auto load for first time uses


" ===
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
"
"Colors
syntax enable
set tabstop=4
set softtabstop=4
set expandtab
"
set number
set showcmd
set cursorline
"filetype indent on
set wildmenu
"set lazyredraw
set showmatch
"
set incsearch
set hlsearch
"set hlsearch off
"fold
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
"Movement
noremap j h
noremap k j
noremap i k
noremap h i
noremap H I
noremap B ^
noremap E $
noremap I 5k
noremap K 5j
" move cursor in insert mode
inoremap <C-j> <Left>
inoremap <C-k> <Down>
inoremap <C-i> <Up>
inoremap <C-l> <Right>
"Savee and quit
noremap S :w<CR>
noremap Q :q<CR>
noremap Z :wq<CR>
inoremap jj <ESC>
"
noremap ; :
let mapleader=' '
" Window management
noremap <LEADER>w <C-w>w
noremap <LEADER>j <C-w>h
noremap <LEADER>k <C-w>j
noremap <LEADER>l <C-w>l
noremap <LEADER>i <C-w>k

" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
noremap si :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sk :set splitbelow<CR>:split<CR>
noremap sj :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sl :set splitright<CR>:vsplit<CR>

" Resize splits with arrow keys
noremap <up> :res +5<CR>
noremap <down> :res -5<CR>
noremap <left> :vertical resize-5<CR>
noremap <right> :vertical resize+5<CR>

" Place the two screens up and down
noremap sh <C-w>t<C-w>K
" Place the two screens side by side
noremap sv <C-w>t<C-w>H

" === Tab management
" ===
" Create a new tab with tu
noremap tu :tabe<CR>
" Move around tabs with tn and ti
noremap tn :-tabnext<CR>
noremap ti :+tabnext<CR>
" Move the tabs with tmn and tmi
noremap tmn :-tabmove<CR>
noremap tmi :+tabmove<CR>

" Compile function
noremap r :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec "!g++ % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'cpp'
        set splitbelow
        exec "!g++ -std=c++11 % -Wall -o %<"
        :sp
        :res -15
        :term ./%<
    elseif &filetype == 'java'
        exec "!javac %"
        exec "!time java %<"
    elseif &filetype == 'sh'
        :!time bash %
    elseif &filetype == 'python'
        set splitbelow
        :sp
        :term python3 %
    elseif &filetype == 'html'
        silent! exec "!".g:mkdp_browser." % &"
    elseif &filetype == 'markdown'
        exec "MarkdownPreview"
    elseif &filetype == 'tex'
        silent! exec "VimtexStop"
        silent! exec "VimtexCompile"
    elseif &filetype == 'dart'
        exec "CocCommand flutter.run -d ".g:flutter_default_device
        CocCommand flutter.dev.openDevLog
    elseif &filetype == 'javascript'
        set splitbelow
        :sp
        :term export DEBUG="INFO,ERROR,WARNING"; node --trace-warnings .
    elseif &filetype == 'go'
        set splitbelow
        :sp
        :term go run .
    endif
endfunc

call plug#begin('~/.vim/plugged')

Plug 'joshdick/onedark.vim'

Plug 'lervag/vimtex'
call plug#end()
"
colorscheme onedark
