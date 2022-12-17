colorscheme catppuccin-macchiato
" Split windows border
" highlight WinSeparator guifg=#d8dee9

set number
set relativenumber

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces to use for autoindent

set mouse=""

" Indents word-wrapped lines as much as the 'parent' line
set breakindent
" Ensures word-wrap does not split words
set formatoptions=l
set lbr

set conceallevel=0

" Fold method
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=1

" set fillchars=fold:\ 
set foldminlines=1

" Neovide font
set guifont=Spleen\ 8x16:h12:b:i

" gm to see highlighting group
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nnoremap gm :call SynStack()<CR>

set conceallevel=0
