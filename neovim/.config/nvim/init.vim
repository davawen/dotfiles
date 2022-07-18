lua require('plugins')

" {{{ Plugins 
call plug#begin(stdpath('data') . '/plugged')

" Themes
Plug 'shaunsingh/nord.nvim'
Plug 'sainnhe/everforest'

Plug 'nvim-lualine/lualine.nvim'
Plug 'startup-nvim/startup.nvim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', { 'do': 'TSUpdateSync' }
Plug 'romgrk/nvim-treesitter-context'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'ray-x/lsp_signature.nvim'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

Plug 'weilbith/nvim-code-action-menu'
Plug 'simrat39/rust-tools.nvim'
Plug 'mhartington/formatter.nvim'

" Syntax highlight
Plug 'brgmnn/vim-opencl'
Plug 'tikhomirov/vim-glsl'
Plug 'timtro/glslView-nvim'
Plug 'evanleck/vim-svelte'

" Filetype specific
Plug 'timonv/vim-cargo'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }

" Navigation
Plug 'nvim-telescope/telescope.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'voldikss/vim-floaterm'

" Other
Plug 'wakatime/vim-wakatime'
Plug 'tomtom/templator_vim'
Plug 'junegunn/vim-easy-align'
Plug 'numToStr/Comment.nvim'

Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'nvim-lua/plenary.nvim'
Plug 'folke/todo-comments.nvim'

Plug 'sotte/presenting.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons'
call plug#end()

" }}} Plugins end

colorscheme nord

" Load filetypes with lua (Neovim 0.7)
let g:do_filetype_lua = 1
let g:did_load_filetypes = 0

"" Top level config {{{
set number
set relativenumber

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces to use for autoindent

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

let mapleader=";"

" }}}

" Remove neo-tree legacy commands before plugin is loaded
let g:neo_tree_remove_legacy_commands = 1

" Lua configuration
lua << EOF
-- Remove config file from cached files in case init.vim is reloaded
for k, v in pairs(package.loaded) do
    if string.match(k, "^config") then
		package.loaded[k] = nil
    end
end
EOF
lua require("config")

" Force h j k l
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>
nnoremap <Down> <nop>

" Space opens command menu
nnoremap <space> :

" Force <c-c> for escape
inoremap <esc> <nop>
inoremap <C-c> <esc>
inoremap <C-v> <esc>

" Fix weird issue with barbar.nvim
nnoremap <esc> <esc>

" Avoid yanking replaced text
vnoremap p "_dP

" ;; add semicolon at the end of the line
nnoremap <leader>; mpA;<esc>`p

" ;s cycles through unnamed and clipboard registers
nnoremap <Leader>s :let @a=@" \| let @"=@+ \| let @+=@a<CR>

" Set ;ev to open configs
nnoremap <leader>ev1 :vsp<cr><c-w>l:e $MYVIMRC<cr>
nnoremap <leader>ev2 :vsp<cr><c-w>l:e ~/.config/nvim/lua/config.lua<cr>

" Open terminal
nnoremap <silent><leader>te <Cmd>FloatermToggle<Cr>
tmap <silent><leader>te <Esc><leader>te

" ctrl-u uppercases a word
inoremap <c-u> <esc>viwUea

" Escape to quit terminal
tnoremap <esc> <C-\><C-n>

" gm to see highlighting group
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nnoremap gm :call SynStack()<CR>

" Save current buffer using root privileges
" Does not work with neovim currently
" command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

" Creates a terminal in a right split
command Vte vsplit | execute "normal! \<c-w>l" | term

" Creates a terminal in a new tab
command Nte tabnew | term

" Creates a terminal in a split and executes a command in it
command -nargs=+ Sh split | execute "normal! \<c-w>j" | term <args>;$SHELL

" Executes "build.sh" in the current context then start a new shell
func Build()
	if &buftype ==# 'terminal'
	else
		execute "split"
		execute "normal! \<c-w>j"
	endif
	
	execute "term source ./build.sh; $SHELL"
	execute "normal! i"
endfunc
command Build call Build()

nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>n :Neotree source=filesystem reveal position=float toggle <CR>
nnoremap <leader>b :Neotree source=buffers reveal position=float toggle <CR>

nnoremap <leader><left> <c-w>h
nnoremap <leader><right> <c-w>l
nnoremap <leader><up> <c-w>k
nnoremap <leader><down> <c-w>j

nnoremap <leader>h <c-w>h
nnoremap <leader>l <c-w>l
nnoremap <leader>k <c-w>k
nnoremap <leader>j <c-w>j

" Put a & at the start of the word
func Ampersand()
	execute "normal! mpviwo\<esc>h"
	
	let char = getline('.')[col('.')-1]

	if char ==# '&'
		execute "normal! x`ph"
	else
		if col('.') > 1
			execute "normal! l"
		endif
		execute "normal! i&\<esc>`pl"
	endif
endfunc

nnoremap & :call Ampersand()<cr>

" {{{ floaterm config

let g:floaterm_width=0.5
let g:floaterm_height=1.0
let g:floaterm_position="right"

" }}}

" {{{ ultisnips config
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" }}}

" {{{ vim-surround config

let g:AutoPairs = {'(':')', '[':']', '{':'}','"':'"', "`":"`", '```':'```', '"""':'"""', "'''":"'''"}

" }}}

" {{{ vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" Get current git branch {{{
function! GitBranch()
	return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction
" }}}

" Autocommands {{{
augroup filetype
	autocmd!
	autocmd FileType vim setlocal wrap foldmethod=marker
	autocmd BufRead,BufNewFile *.dotvm set filetype=dotvm
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

augroup buffers
	autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
"}}}

" Status line {{{
" let g:airline#extensions#clock#format = ' %k:%M:%S %p'
" let g:airline#extensions#clock#updatetime = 1000
" 
" function! AirlineInit()
" 	call airline#extensions#whitespace#disable()
" 	call airline#switch_theme('nord_minimal')
" endfunction
" 
" augroup VimAirline
" 	autocmd User AirlineAfterInit call AirlineInit()
" augroup END
"}}}

" Cmp Highlight {{{
highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#616E88

highlight! CmpItemAbbrMatch guibg=NONE guifg=#B48EAD
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#B48EAD=

highlight! CmpItemKindVariable guibg=NONE guifg=#81A1C1
highlight! CmpItemKindClass guibg=NONE guifg=#81A1C1
highlight! CmpItemKindInterface guibg=NONE guifg=#81A1C1
highlight! CmpItemKindText guibg=NONE guifg=#81A1C1

highlight! CmpItemKindFunction guibg=NONE guifg=#88C0D0
highlight! CmpItemKindConstructor guibg=NONE guifg=#88C0D0
highlight! CmpItemKindMethod guibg=NONE guifg=#88C0D0

highlight! CmpItemKindKeyword guibg=NONE guifg=#81A1C1
highlight! CmpItemKindProperty guibg=NONE guifg=#81A1C1
highlight! CmpItemKindUnit guibg=NONE guifg=#81A1C1

highlight! CmpItemKindEnum guibg=NONE guifg=#EBCB8B
highlight! CmpItemKindEnumMember guibg=NONE guifg=#EBCB8B
highlight! CmpItemKindConstant guibg=NONE guifg=#EBCB8B
highlight! CmpItemKindConstant guibg=NONE guifg=#EBCB8B
"}}}

" {{{ Vim-Markdown Config
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0

let g:tex_conceal = ""
let g:vim_markdown_math = 1

let g:vim_markdown_frontmatter = 1  " for YAML format
let g:vim_markdown_toml_frontmatter = 1  " for TOML format
let g:vim_markdown_json_frontmatter = 1  " for JSON format

" }}} Vim-Markdown Config

set conceallevel=0

