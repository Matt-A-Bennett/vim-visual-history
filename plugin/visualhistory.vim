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
" Version:      0.7.1
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

"{{{- initialise variables -----------------------------------------------------
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
    let b:prev_cursor_pos = getpos('.')
endfunction
"}}}---------------------------------------------------------------------------

"================================ FUNCTIONS ===================================

""{{{- turn_on_cursor_tracking -------------------------------------------------
"function! s:turn_on_cursor_tracking()
"    " call s:update_cursor_pos()
"    augroup cursor_tracking
"        autocmd!
"        autocmd CursorMoved * call <SID>update_visual_mark_list()
"    augroup END
"endfunction
""}}}---------------------------------------------------------------------------

""{{{- turn_off_cursor_tracking ------------------------------------------------
"function! s:turn_off_cursor_tracking()
"    " call s:check_motion()
"    augroup cursor_tracking
"        autocmd!
"    augroup END
"endfunction
""}}}---------------------------------------------------------------------------

"{{{- update_pointer ----------------------------------------------------------
function! s:update_pointer(direction)
    let b:vis_mark_record_pointer += a:direction
endfunction
"}}}---------------------------------------------------------------------------

""{{{- get_visual_position -----------------------------------------------------
"function! s:get_visual_position(vis_mode)
"    execute "normal! \<ESC>"
"    let [_, l1, c1, _] = getpos("'<")
"    let [_, l2, c2, _] = getpos("'>")
"    normal! gv
"    if c1 == 0
"        let c1 = 1
"    endif
"    if c2 > 1000
"        let c2 = col("$")
"    endif
"    return [[l1, c1], [l2, c2], a:vis_mode]
"endfunction
""}}}---------------------------------------------------------------------------

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

"{{{- remove_record_entry -----------------------------------------------------------
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

""{{{- update_visual_mark_list -------------------------------------------------
"function! s:update_visual_mark_list()
"    if b:reselecting == 1
"        let b:reselecting = 0
"        return
"    endif
"    let mode = mode()
"    if mode ==# 'v' || mode ==# 'V' || mode ==# "\<C-V>"
"        let vis_pos = s:get_visual_position(mode)
"        call s:add_record_entry(vis_pos)
"    endif
"endfunction
""}}}---------------------------------------------------------------------------

"{{{- lines_added_or_removed ---------------------------------------------------
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

"{{{- process_direction -------------------------------------------------------
function! s:process_direction(direction)
    if type(a:direction) == type(0)
        let direction = a:direction*v:count1
    elseif a:direction ==# 'first'
        let b:vis_mark_record_pointer = 2
        let direction = -1
    elseif a:direction ==# 'last'
        let b:vis_mark_record_pointer = len(b:vis_mark_record)-1
        let direction = 1
    endif
    return direction
endfunction
"}}}---------------------------------------------------------------------------

"{{{- reselect_visual_from_record ---------------------------------------------
function! s:reselect_visual_from_record(direction)
    let direction = s:process_direction(a:direction)
    if b:vis_mark_record_pointer+2 >= len(b:vis_mark_record) && direction == 1 ||
     \ b:vis_mark_record_pointer   <= 1                      && direction == -1
        normal! gv
        return
    endif
    let b:reselecting = 1
    call s:update_pointer(direction)
    let [l1, c1, l2, c2, vis_mode] = s:extract_record_entry()
    execute "normal! \<ESC>"
    call cursor(l1, c1)
    execute "normal! ".vis_mode
    call cursor(l2, c2)
endfunction
"}}}---------------------------------------------------------------------------

"======================== CREATE MAPS AND AUTOCMDS ============================

function! s:get_visual_position2()
    let [_, l1, c1, _] = getpos("'<")
    let [_, l2, c2, _] = getpos("'>")
    if c1 == 0
        let c1 = 1
    endif
    if c2 > 1000
        let c2 = len(getline(l2))
    endif
    return [[l1, c1], [l2, c2], visualmode()]
endfunction

function! s:dumb()
    if b:reselecting == 1
        let b:reselecting = 0
        return
    endif
    let vis_pos = s:get_visual_position2()
    call s:add_record_entry(vis_pos)
endfunction

"{{{- set up autocmds ---------------------------------------------------------
autocmd BufEnter                  * call <SID>initialise_variables(0)
autocmd TextChanged,InsertLeave   * call <SID>sync_record()

autocmd CursorMoved    * call <SID>dumb()

" if exists("##ModeChanged")
"     autocmd ModeChanged *:[vV]    call <SID>turn_on_cursor_tracking()
"     autocmd ModeChanged [vV]:*    call <SID>turn_off_cursor_tracking()
" else
"     autocmd CursorMoved           * call <SID>update_visual_mark_list()
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
