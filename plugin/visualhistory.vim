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
" Version:      0.8.0
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

"{{{- initialise variables ----------------------------------------------------
function! s:initialise_variables(reset)
    if !exists("b:vis_mark_record") || a:reset == 1
        let b:vis_mark_record = []
        let b:vis_mark_record_pointer = 0
        let b:old_number_of_lines = line('$')
        if ! exists("g:visual_history_length")
            let b:record_length = 100
        else
            let b:record_length = g:visual_history_length
        endif
    endif
    let b:reselecting = 0
    let b:selection_check_count = 3
endfunction
"}}}---------------------------------------------------------------------------

"================================ FUNCTIONS ===================================

"{{{- update_pointer ----------------------------------------------------------
function! s:update_pointer(direction)
    let direction = a:direction
    if direction ==# 'first'
        let b:vis_mark_record_pointer = 1
    elseif direction ==# 'last'
        let b:vis_mark_record_pointer = len(b:vis_mark_record)-1
    else
        let direction = direction*v:count1
        if b:vis_mark_record_pointer+direction <= 1
            let b:vis_mark_record_pointer = 1
        elseif b:vis_mark_record_pointer+direction >= len(b:vis_mark_record)
            let b:vis_mark_record_pointer = len(b:vis_mark_record)-1
        else
            let b:vis_mark_record_pointer += direction
        endif
    endif
endfunction
"}}}---------------------------------------------------------------------------

"{{{- get_visual_position -----------------------------------------------------
function! s:get_visual_position()
    let mode = mode()
    if mode == 'v' || mode == 'V' || mode == "\<C-V>"
        let [_, l1, c1, _] = getpos("v")
        let [_, l2, c2, _] = getpos(".")
    else
        let [_, l1, c1, _] = getpos("'<")
        let [_, l2, c2, _] = getpos("'>")
        let mode = visualmode()
    endif
    if c1 == 0
        let c1 = 1
    endif
    if c1 > 1000
        let c1 = len(getline(l1))
    endif
    if c2 == 0
        let c2 = 1
    endif
    if c2 > 1000
        let c2 = len(getline(l2))
    endif
    return [[l1, c1], [l2, c2], mode]
endfunction
"}}}---------------------------------------------------------------------------

"{{{- add_record_entry --------------------------------------------------------
function! s:add_record_entry(vis_pos)
    " if the history is empty, or the last entry is different
    if len(b:vis_mark_record) == 0 || b:vis_mark_record[-1] != a:vis_pos
        call add(b:vis_mark_record, a:vis_pos)
        call s:update_pointer(1)
        if len(b:vis_mark_record) > b:record_length
            call remove(b:vis_mark_record, 0)
        endif
    endif
endfunction
"}}}---------------------------------------------------------------------------

"{{{- remove_record_entry -----------------------------------------------------
function! s:remove_record_entry(entry_number)
    call remove(b:vis_mark_record, a:entry_number)
    if b:vis_mark_record_pointer >= a:entry_number
        let b:vis_mark_record_pointer -= 1
    endif
endfunction
"}}}---------------------------------------------------------------------------

"{{{- extract_record_entry ----------------------------------------------------
function! s:extract_record_entry()
    let l1 = b:vis_mark_record[b:vis_mark_record_pointer][0][0]
    let c1 = b:vis_mark_record[b:vis_mark_record_pointer][0][1]
    let l2 = b:vis_mark_record[b:vis_mark_record_pointer][1][0]
    let c2 = b:vis_mark_record[b:vis_mark_record_pointer][1][1]
    let vis_mode = b:vis_mark_record[b:vis_mark_record_pointer][2]
    return [l1, c1, l2, c2, vis_mode]
endfunction
"}}}---------------------------------------------------------------------------

"{{{- selection_checks --------------------------------------------------------
function! s:selection_checks(switch)
    if exists("##ModeChanged")
        if type(a:switch) == type(0)
            let b:selection_check_count = a:switch
        endif
        let b:selection_check_count -= 1
    endif
    return b:selection_check_count
endfunction
"}}}---------------------------------------------------------------------------

"{{{- update_record -----------------------------------------------------------
function! s:update_record()
    if b:reselecting == 1
        let b:reselecting = 0
        return
    endif
    " if s:selection_checks('check') > 0
        let vis_pos = s:get_visual_position()
        if vis_pos[-1] == 'v' || vis_pos[-1] == 'V' || vis_pos[-1] == "\<C-V>"
            " do nothing
        else
            let vis_pos[-1] = 'v'
        endif
        call s:add_record_entry(vis_pos)
    " endif
endfunction
"}}}---------------------------------------------------------------------------

"{{{- lines_added_or_removed --------------------------------------------------
function! s:lines_added_or_removed()
    let b:current_number_of_lines = line('$')
    let difference = b:current_number_of_lines - b:old_number_of_lines
    let b:old_number_of_lines = b:current_number_of_lines
    return difference
endfunction
"}}}---------------------------------------------------------------------------

"{{{- sync_record -------------------------------------------------------------
function! s:sync_record()
    let difference = s:lines_added_or_removed() 
    let g:difference = difference
    if difference == 0
        return
    else
        let [_, first_changed_line, _, _] = getpos("'[")
        let [_, last_changed_line, _, _] = getpos("']")
        let record_count = 0
        for record in b:vis_mark_record
            let overlap1 = record[0][0] - first_changed_line + 1
            let overlap2 = record[1][0] - first_changed_line + 1
            if (overlap1 > 0 && overlap1 <= -difference) &&
             \ (overlap2 > 0 && overlap2 <= -difference)
                call s:remove_record_entry(record_count)
                let record_count -= 1
            elseif overlap1 > 0 && overlap1 <= -difference
                let b:vis_mark_record[record_count][0][0] = last_changed_line
                let b:vis_mark_record[record_count][1][0] += difference
            elseif record[0][0] >= first_changed_line
                let b:vis_mark_record[record_count][0][0] += difference
                let b:vis_mark_record[record_count][1][0] += difference
            elseif record[1][0] >= first_changed_line
                let b:vis_mark_record[record_count][1][0] += difference
            endif
            let record_count += 1
        endfor
    endif
endfunction
"}}}---------------------------------------------------------------------------

"{{{- reselect_visual_from_record ---------------------------------------------
function! s:reselect_visual_from_record(direction)
    if len(b:vis_mark_record) == 1 && b:vis_mark_record[0][2] == ''
        normal! gv
        return
    endif
    call s:update_pointer(a:direction)
    let b:reselecting = 1
    let [l1, c1, l2, c2, vis_mode] = s:extract_record_entry()
    execute "normal! \<ESC>"
    call cursor(l1, c1)
    execute "normal! ".vis_mode
    call cursor(l2, c2)
endfunction
"}}}---------------------------------------------------------------------------

"======================== CREATE MAPS AND AUTOCMDS ============================

"{{{- set up autocmds ---------------------------------------------------------
autocmd BufEnter                  * call <SID>initialise_variables(0)
autocmd TextChanged,InsertLeave   * call <SID>sync_record()
autocmd CursorMoved               * call <SID>update_record()

" if exists("##ModeChanged")
"     autocmd ModeChanged *:[vV]    call <SID>selection_checks(0)
"     autocmd ModeChanged [vV]:*    call <SID>selection_checks(3)
" endif
"}}}---------------------------------------------------------------------------

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

    if !exists(":ClearVisualHistory")
        command ClearVisualHistory :call s:initialise_variables(1)
    endif
endif
"}}}---------------------------------------------------------------------------

"==============================================================================
