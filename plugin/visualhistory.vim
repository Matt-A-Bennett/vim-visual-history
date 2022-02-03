"==============================================================================
"    __ __ ____ _______ __  ____ _           __    __  ____ _     __  _ 
"    |  |  |    / ___/  |  |/    | |         |  |__|  |/    | |   |  |/ ]
"    |  |  ||  (   \_|  |  |  o  | |    _____|  |  |  |  o  | |   |  ' / 
"    |  |  ||  |\__  |  |  |     | |___|     |  |  |  |     | |___|    \ 
"    |  :  ||  |/  \ |  :  |  _  |     |_____|  `  '  |  _  |     |     \
"     \   / |  |\    |     |  |  |     |      \      /|  |  |     |  .  |
"      \_/ |____|\___|\__,_|__|__|_____|       \_/\_/ |__|__|_____|__|\_|
"     
"
" Author:       Matthew Bennett
" Version:      0.1.0
" License:      Same as Vim's (see :help license)
"
"
"======================== EXPLANATION OF THE APPROACH =========================


"================================== SETUP =====================================

"{{{- guard against reloading -------------------------------------------------
if exists("g:loaded_visual_walk") || &cp || v:version < 700
    finish
endif
let g:loaded_visual_walk = 1
"}}}---------------------------------------------------------------------------

"     1     "
"     2     "
"     3     "
"     4     "
"     5     "
"     6     "
"     7     "
"     8     "
"     9     "
"     10    "


let g:vis_mark_record = []
let g:vis_mark_record_pointer = 0
let g:record_length = 100

let g:reselecting = 0

function! Update_pointer(direction)
    let g:vis_mark_record_pointer += a:direction
endfunction

function! Get_visual_position(vis_mode)
    execute "normal! \<ESC>"
    let [_, l1, c1, _] = getpos("'<")
    let [_, l2, c2, _] = getpos("'>")
    normal! gv
    if c1 == 0
        let c1 = 1
    endif
    if c2 > 1000
        let c2 = col("$")
    endif
    return [[l1, c1], [l2, c2], a:vis_mode]
endfunction

function! Update_visual_mark_list()
    if g:reselecting == 1
        let g:reselecting = 0
        return
    endif
    let vis_mode = mode()
    if vis_mode ==# 'v' || vis_mode ==# 'V' || vis_mode ==# "\<C-V>"
        if len(g:vis_mark_record) > 0 && len(g:vis_mark_record) > g:record_length
            call remove(g:vis_mark_record, 0)
        endif
        let vis_pos = Get_visual_position(vis_mode)
        call add(g:vis_mark_record, vis_pos)
        call Update_pointer(1)
    endif
endfunction

function! Get_record()
    let l1 = g:vis_mark_record[g:vis_mark_record_pointer][0][0]
    let c1 = g:vis_mark_record[g:vis_mark_record_pointer][0][1]
    let l2 = g:vis_mark_record[g:vis_mark_record_pointer][1][0]
    let c2 = g:vis_mark_record[g:vis_mark_record_pointer][1][1]
    let vis_mode = g:vis_mark_record[g:vis_mark_record_pointer][2]
    return [l1, c1, l2, c2, vis_mode]
endfunction

function! Reselect_visual_from_record(direction, type)
    let direction = a:direction
    if direction ==# 'first'
        let g:vis_mark_record_pointer = 1
        let direction = -1
    elseif direction ==# 'last'
        let g:vis_mark_record_pointer = len(g:vis_mark_record)-2
        let direction = 1
    endif
    if g:vis_mark_record_pointer+1 >= len(g:vis_mark_record) && direction == 1 ||
     \ g:vis_mark_record_pointer   <= 0                      && direction == -1
        normal! gv
        return
    endif
    let g:reselecting = 1
    call Update_pointer(direction)
    let [l1, c1, l2, c2, vis_mode] = Get_record()
    execute "normal! \<ESC>"
    call cursor(l1, c1)
    execute "normal! ".vis_mode
    normal!.o
    call cursor(l2, c2)
endfunction

augroup visual_walk
    autocmd!
    autocmd CursorMoved * call Update_visual_mark_list()
    vnoremap <silent> [v :<C-U>call Reselect_visual_from_record(-1, visualmode())<CR>
    vnoremap <silent> ]v :<C-U>call Reselect_visual_from_record(1, visualmode())<CR>
    vnoremap <silent> [V :<C-U>call Reselect_visual_from_record('first', visualmode())<CR>
    vnoremap <silent> ]V :<C-U>call Reselect_visual_from_record('last', visualmode())<CR>
augroup END

