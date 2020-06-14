"Colors
"colorscheme badwolf
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
noremap B ^
noremap E $
"
let mapleader=' '

noremap I 5k
noremap K 5j
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



