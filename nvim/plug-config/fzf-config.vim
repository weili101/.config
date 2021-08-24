" Mapping electing mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
"imap <c-w> <plug>(fzf-complete-word)
imap <c-p> <plug>(fzf-complete-path)
"imap <c-l> <plug>(fzf-complete-line)

nnoremap <silent> <leader>f :Files <CR>
