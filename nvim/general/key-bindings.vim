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
noremap te :tabe<CR>
" Move around tabs with tn and ti
noremap tj :-tabnext<CR>
noremap tl :+tabnext<CR>
" Move the tabs with tmn and tmi
noremap ti :-tabmove<CR>
noremap tk :+tabmove<CR>


