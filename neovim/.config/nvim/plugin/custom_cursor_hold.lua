-- Somehow, for some fucking reason, neovim won't load .vim files in the plugin directory

vim.cmd [[
" Maintainer:   Antoine Madec <aja.madec@gmail.com>
" Credit: https://github.com/antoinemadec/FixCursorHold.nvim/blob/master/plugin/fix_cursorhold_nvim.vim

let g:cursorhold_updatetime = get(g:, 'cursorhold_updatetime', &updatetime)
let g:fix_cursorhold_nvim_timer = -1
set eventignore+=CursorHold,CursorHoldI

augroup fix_cursorhold_nvim
  autocmd!
  autocmd CursorMovedI * call CursorHoldITimer()
augroup end

function CursorHoldI_Cb(timer_id) abort
  if v:exiting isnot v:null
    return
  endif

  set eventignore-=CursorHoldI
  doautocmd <nomodeline> CursorHoldI
  set eventignore+=CursorHoldI
endfunction

function CursorHoldITimer() abort
  call timer_stop(g:fix_cursorhold_nvim_timer)
  let g:fix_cursorhold_nvim_timer = timer_start(g:cursorhold_updatetime, 'CursorHoldI_Cb')
endfunction
]]