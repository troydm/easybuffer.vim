" easybuffer.vim - plugin to quickly switch between buffers
" Maintainer: Dmitry "troydm" Geurkov <d.geurkov@gmail.com>
" Version: 0.1.4
" Description: easybuffer.vim is a simple plugin to quickly
" switch between buffers by just pressing keys 
" Last Change: 13 February, 2013
" License: Vim License (see :help license)
" Website: https://github.com/troydm/easybuffer.vim
"
" See easybuffer.vim for help.  This can be accessed by doing:
" :help easybuffer

let s:save_cpo = &cpo
set cpo&vim

" options {{{
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
