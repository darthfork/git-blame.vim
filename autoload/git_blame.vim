" Plugin Name: Git Blame
" Author: Abhishek Rai
" Version: 1.0
" Description: This plugin integrates git blame functionality in Vim.

function! git_blame#Blame()
    " Get the current file path and directory
    let current_file = resolve(expand('%:p'))
    let current_dir = fnamemodify(current_file, ":h")

    " Get the start and end lines for the Git log command
    let start_line = line("v")
    let end_line = line(".")

    " Build the git log command
    let git_command = "cd " . shellescape(current_dir) .
          \ " && git log --no-merges -n 1 -L " . shellescape(start_line . "," . end_line . ":" . current_file)

    " Call systemlist with the git command
    let blame_output = systemlist(git_command)

    " Check if we are in Neovim
    if exists('*nvim_open_win')
        " Neovim: use nvim_open_win for floating windows
        call s:show_floating_window(blame_output)
    else
        " Vim: use popup_atcursor for popup windows
        call setbufvar(
              \ winbufnr(popup_atcursor(blame_output, {
              \ 'padding': [1,1,1,1], 'pos': 'botleft', 'wrap': 0 })),
              \ '&filetype', 'git')
    endif
endfunction

" Function to show a floating window in Neovim
function! s:show_floating_window(contents)
    " Create a new scratch buffer for the blame output
    let buf = nvim_create_buf(v:false, v:true)

    " Set the contents of the buffer
    call nvim_buf_set_lines(buf, 0, -1, v:true, a:contents)

    " Define window settings for the floating window
    let width = max(map(a:contents, 'strwidth(v:val)')) + 4
    let height = len(a:contents) + 2
    let opts = {
                \ 'relative': 'cursor',
                \ 'row': 1,
                \ 'col': 1,
                \ 'width': width,
                \ 'height': height,
                \ 'style': 'minimal',
                \ 'border': 'single'
                \ }

    " Open the floating window
    let win = nvim_open_win(buf, v:true, opts)

    " Set the filetype to git in the floating window
    call nvim_buf_set_option(buf, 'filetype', 'git')

    " Close the floating window with movement keys
    call s:map_close_keys(buf, win)
endfunction

" Function to map movement keys to close the window
function! s:map_close_keys(buf, win)
    " Define keys that should close the window
    let keys = ['h', 'j', 'k', 'l', '<Esc>']

    " Loop through each key and map it to close the window
    for key in keys
        call nvim_buf_set_keymap(a:buf, 'n', key, ':q<CR>', {'nowait': v:true, 'noremap': v:true, 'silent': v:true})
    endfor
endfunction
