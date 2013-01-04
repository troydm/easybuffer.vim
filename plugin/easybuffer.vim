" easybuffer.vim - plugin to quickly switch between buffers
" Maintainer: Dmitry "troydm" Geurkov <d.geurkov@gmail.com>
" Version: 0.1.3
" Description: easybuffer.vim is a simple plugin to quickly
" switch between buffers by just pressing keys 
" Last Change: 16 September, 2012
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
command! -bang EasyBuffer call easybuffer#OpenEasyBuffer('<bang>',g:easybuffer_keep.'edit')
command! -bang EasyBufferClose call easybuffer#CloseEasyBuffer()
command! -bang EasyBufferToggle call easybuffer#ToggleEasyBuffer()
command! -bang EasyBufferHorizontal call easybuffer#OpenEasyBuffer('<bang>',g:easybuffer_keep.(&lines/2).'sp')
command! -bang EasyBufferHorizontalBelow call easybuffer#OpenEasyBuffer('<bang>',g:easybuffer_keep.'belowright '.(&lines/2).'sp')
command! -bang EasyBufferVertical call easybuffer#OpenEasyBuffer('<bang>',g:easybuffer_keep.(&columns/2).'vs')
command! -bang EasyBufferVerticalRight call easybuffer#OpenEasyBuffer('<bang>',g:easybuffer_keep.'belowright '.(&columns/2).'vs')

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
