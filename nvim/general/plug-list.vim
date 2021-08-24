call plug#begin('$HOME/.config/nvim/plugged') 
"Plugin Section
" Treesitter
"Plug 'nvim-treesitter/nvim-treesitter'
"Plug 'nvim-treesitter/playground'

" Auto Complete
"Plug 'neoclide/coc.nvim', {'branch': 'release'}

"Plug 'preservim/nerdtree'

Plug 'sirver/ultisnips'
Plug 'lervag/vimtex'

Plug 'joshdick/onedark.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'preservim/nerdcommenter'

if has('nvim')
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-compe'
endif
call plug#end()

" Plug configs
" color scheme
syntax on
colorscheme onedark

