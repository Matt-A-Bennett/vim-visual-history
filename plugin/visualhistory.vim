"==============================================================================
" __ __ ____ _______ __  ____ _           __ __ ____ ___________  ___  ____  __ __ 
" |  |  |    / ___/  |  |/    | |         |  |  |    / ___/      |/   \|    \|  |  |
" |  |  ||  (   \_|  |  |  o  | |    _____|  |  ||  (   \_|      |     |  D  )  |  |
" |  |  ||  |\__  |  |  |     | |___|     |  _  ||  |\__  |_|  |_|  O  |    /|  ~  |
" |  :  ||  |/  \ |  :  |  _  |     |_____|  |  ||  |/  \ | |  | |     |    \|___, |
"  \   / |  |\    |     |  |  |     |     |  |  ||  |\    | |  | |     |  .  \     |
"   \_/ |____|\___|\__,_|__|__|_____|     |__|__|____|\___| |__|  \___/|__|\_|____/ 
"                                                                                        
"
" Author:       Matthew Bennett
" Version:      0.3.2
" License:      Same as Vim's (see :help license)
"
"
"================================== SETUP =====================================

"{{{- guard against reloading -------------------------------------------------
if exists("g:loaded_visual_history") || &cp || v:version < 700
    finish
endif
let g:loaded_visual_history = 1
"}}}---------------------------------------------------------------------------

"{{{- initalise variables -----------------------------------------------------
function! s:initalise_variables()
    if !exists("b:vis_mark_record")
        let b:vis_mark_record = []
        let b:vis_mark_record_pointer = 0
        if ! exists("g:visual_history_record_length")
            let b:record_length = 100
        else
            let b:record_length = g:visual_history_record_length
        endif
    endif
    let b:reselecting = 0
endfunction
"}}}---------------------------------------------------------------------------

"==============================================================================

"{{{- update_pointer ----------------------------------------------------------
function! s:update_pointer(direction)
    let b:vis_mark_record_pointer += a:direction
endfunction
"}}}---------------------------------------------------------------------------

"{{{- get_visual_position -----------------------------------------------------
function! s:get_visual_position(vis_mode)
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
"}}}---------------------------------------------------------------------------

"{{{- update_visual_mark_list -------------------------------------------------
function! s:update_visual_mark_list()
    if b:reselecting == 1
        let b:reselecting = 0
        return
    endif
    let mode = mode()
    if mode ==# 'v' || mode ==# 'V' || mode ==# "\<C-V>"
        if len(b:vis_mark_record) > 0 && len(b:vis_mark_record) > b:record_length
            call remove(b:vis_mark_record, 0)
        endif
        let vis_pos = s:get_visual_position(mode)
        call add(b:vis_mark_record, vis_pos)
        call s:update_pointer(1)
    endif
endfunction
"}}}---------------------------------------------------------------------------

"{{{- get_record --------------------------------------------------------------
function! s:get_record()
    let l1 = b:vis_mark_record[b:vis_mark_record_pointer][0][0]
    let c1 = b:vis_mark_record[b:vis_mark_record_pointer][0][1]
    let l2 = b:vis_mark_record[b:vis_mark_record_pointer][1][0]
    let c2 = b:vis_mark_record[b:vis_mark_record_pointer][1][1]
    let vis_mode = b:vis_mark_record[b:vis_mark_record_pointer][2]
    return [l1, c1, l2, c2, vis_mode]
endfunction
"}}}---------------------------------------------------------------------------

"{{{- reselect_visual_from_record ---------------------------------------------
function! s:reselect_visual_from_record(direction)
    let direction = a:direction
    if direction ==# 'first'
        let b:vis_mark_record_pointer = 1
        let direction = -1
    elseif direction ==# 'last'
        let b:vis_mark_record_pointer = len(b:vis_mark_record)-2
        let direction = 1
    endif
    if b:vis_mark_record_pointer+1 >= len(b:vis_mark_record) && direction == 1 ||
     \ b:vis_mark_record_pointer   <= 0                      && direction == -1
        normal! gv
        return
    endif
    let b:reselecting = 1
    call s:update_pointer(direction)
    let [l1, c1, l2, c2, vis_mode] = s:get_record()
    execute "normal! \<ESC>"
    call cursor(l1, c1)
    execute "normal! ".vis_mode
    normal!.o
    call cursor(l2, c2)
endfunction
"}}}---------------------------------------------------------------------------

autocmd CursorMoved * call <SID>update_visual_mark_list()
autocmd BufEnter    * call <SID>initalise_variables()

"=============================== CREATE MAPS ==================================

"{{{- define plug function calls ----------------------------------------------
vnoremap <silent> <Plug>(SelectPrevious) :<C-U>call <SID>reselect_visual_from_record(-1)<CR>
vnoremap <silent> <Plug>(SelectNext)     :<C-U>call <SID>reselect_visual_from_record(1)<CR>
vnoremap <silent> <Plug>(SelectFirst)    :<C-U>call <SID>reselect_visual_from_record('first')<CR>
vnoremap <silent> <Plug>(SelectLast)     :<C-U>call <SID>reselect_visual_from_record('last')<CR>

nnoremap <silent> <Plug>(SelectPrevious) :<C-U>call <SID>reselect_visual_from_record(-1)<CR>
nnoremap <silent> <Plug>(SelectNext)     :<C-U>call <SID>reselect_visual_from_record(1)<CR>
nnoremap <silent> <Plug>(SelectFirst)    :<C-U>call <SID>reselect_visual_from_record('first')<CR>
nnoremap <silent> <Plug>(SelectLast)     :<C-U>call <SID>reselect_visual_from_record('last')<CR>
"}}}---------------------------------------------------------------------------

"{{{- create maps and text objects --------------------------------------------
if !exists("g:visual_history_create_mappings") || g:visual_history_create_mappings != 0

    " visual mode commands
    vmap <silent> [v <Plug>(SelectPrevious)
    vmap <silent> ]v <Plug>(SelectNext)
    vmap <silent> [V <Plug>(SelectFirst)
    vmap <silent> ]V <Plug>(SelectLast)

    " normal mode commands
    nmap <silent> [v <Plug>(SelectPrevious)
    nmap <silent> ]v <Plug>(SelectNext)
    nmap <silent> [V <Plug>(SelectFirst)
    nmap <silent> ]V <Plug>(SelectLast)

endif
"}}}---------------------------------------------------------------------------

"==============================================================================
