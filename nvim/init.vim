" General settings
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/general/key-bindings.vim
source $HOME/.config/nvim/general/plug-list.vim
"
source $HOME/.config/nvim/plug-config/vimtex.vim
source $HOME/.config/nvim/plug-config/snips-config.vim
"source $HOME/.config/nvim/plug-config/nerdtree.vim

source $HOME/.config/nvim/plug-config/airline.vim

source $HOME/.config/nvim/plug-config/fzf-config.vim

if has('nvim')
  source $HOME/.config/nvim/plug-config/tex-lsp.lua
  source $HOME/.config/nvim/plug-config/complete-config.lua
endif
