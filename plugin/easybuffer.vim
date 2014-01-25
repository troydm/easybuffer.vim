" easybuffer.vim - plugin to quickly switch between buffers
" Maintainer: Dmitry "troydm" Geurkov <d.geurkov@gmail.com>
" Version: 0.1.5
" Description: easybuffer.vim is a simple plugin to quickly
" switch between buffers by just pressing keys 
" Last Change: 25 January, 2014
" License: Vim License (see :help license)
" Website: https://github.com/troydm/easybuffer.vim
"
" See easybuffer.vim for help.  This can be accessed by doing:
" :help easybuffer

let s:save_cpo = &cpo
set cpo&vim

" options {{{
if !exists("g:easybuffer_chars")
    let g:easybuffer_chars = ['a','s','f','w','e','z','x','c','v']
endif

if !exists("g:easybuffer_bufname")
    let g:easybuffer_bufname = "bname"
endif

if !exists("g:easybuffer_cursorline")
    let g:easybuffer_cursorline = 1
endif

if !exists("g:easybuffer_toggle_position")
    let g:easybuffer_toggle_position = 'Current'
endif

if !exists("g:easybuffer_show_header")
    let g:easybuffer_show_header = 1
endif

if !exists("g:easybuffer_horizontal_height")
    let g:easybuffer_horizontal_height = '&lines/2'
endif

if !exists("g:easybuffer_vertical_width")
    let g:easybuffer_vertical_width = '&columns/2'
endif

if !exists("g:easybuffer_use_zoomwintab")
    let g:easybuffer_use_zoomwintab = 0
endif

if !exists("g:easybuffer_use_sequence")
    let g:easybuffer_use_sequence = 0
endif

if !exists("g:easybuffer_sort_clear_mapping")
    let g:easybuffer_sort_clear_mapping = ",,"
endif

if !exists("g:easybuffer_sort_bufnr_asc_mapping")
    let g:easybuffer_sort_bufnr_asc_mapping = ",b"
endif

if !exists("g:easybuffer_sort_bufnr_desc_mapping")
    let g:easybuffer_sort_bufnr_desc_mapping = ",B"
endif

if !exists("g:easybuffer_sort_seq_asc_mapping")
    let g:easybuffer_sort_seq_asc_mapping = ",s"
endif

if !exists("g:easybuffer_sort_seq_desc_mapping")
    let g:easybuffer_sort_seq_desc_mapping = ",S"
endif

if !exists("g:easybuffer_sort_bufname_asc_mapping")
    let g:easybuffer_sort_bufname_asc_mapping = ",n"
endif

if !exists("g:easybuffer_sort_bufname_desc_mapping")
    let g:easybuffer_sort_bufname_desc_mapping = ",N"
endif

if !exists("g:easybuffer_sort_bufmode_asc_mapping")
    let g:easybuffer_sort_bufmode_asc_mapping = ",m"
endif

if !exists("g:easybuffer_sort_bufmode_desc_mapping")
    let g:easybuffer_sort_bufmode_desc_mapping = ",M"
endif

if !exists("g:easybuffer_sort_filetype_asc_mapping")
    let g:easybuffer_sort_filetype_asc_mapping = ",f"
endif

if !exists("g:easybuffer_sort_filetype_desc_mapping")
    let g:easybuffer_sort_filetype_desc_mapping = ",F"
endif

if !exists("g:easybuffer_sort_mode")
    let g:easybuffer_sort_mode = ""
endif

if !exists("g:easybuffer_sort_asc_chr")
    let g:easybuffer_sort_asc_chr = "▾"
endif

if !exists("g:easybuffer_sort_desc_chr")
    let g:easybuffer_sort_desc_chr = "▴"
endif

if !exists("g:easybuffer_bufname")
    let g:easybuffer_bufname = "bname"
endif
" }}}

" check for available command {{{
let g:easybuffer_keep = ''
if exists(":keepalt")
    let g:easybuffer_keep .= 'keepalt '
endif

if exists(":keepjumps")
    let g:easybuffer_keep .= 'keepjumps '
endif
" }}}

" commands {{{1
command! -bang EasyBuffer call easybuffer#OpenEasyBufferCurrent('<bang>')
command! -bang EasyBufferClose call easybuffer#CloseEasyBuffer()
command! -bang EasyBufferToggle call easybuffer#ToggleEasyBuffer('<bang>')
command! -bang EasyBufferHorizontal call easybuffer#OpenEasyBufferHorizontal('<bang>')
command! -bang EasyBufferHorizontalBelow call easybuffer#OpenEasyBufferHorizontalBelow('<bang>')
command! -bang EasyBufferVertical call easybuffer#OpenEasyBufferVertical('<bang>')
command! -bang EasyBufferVerticalRight call easybuffer#OpenEasyBufferVerticalRight('<bang>')

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
