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

" check if already loaded {{{
if !exists('g:easybuffer_loaded')
    let g:easybuffer_loaded = 1
elseif g:easybuffer_loaded
    let &cpo = s:save_cpo
    unlet s:save_cpo
    finish
endif
" }}}

" functions {{{
" string helper functions {{{
function! s:StrCenter(s,l)
    if len(a:s) > a:l
        return a:s
    else
        let i = (a:l - len(a:s))/2
        let s = repeat(' ',i).a:s.repeat(' ',i)
        if len(s) > a:l
            let s = s[: -(len(s)-a:l+1)]
        elseif a:l > len(s)
            let s .= repeat(' ',a:l-len(s))
        endif
        return s
endfunction

function! s:StrRight(s,l)
    if len(a:s) > a:l
        return a:s
    else
        let i = (a:l - len(a:s))
        let s = a:s.repeat(' ',i)
        return s
endfunction
" }}}

" buffer related functions {{{
function! s:SelectBuf(bnr)
    if g:easybuffer_use_zoomwintab && g:zoomwintab_loaded && b:zoomwintab
        silent! ZoomWinTabOut
    endif
    if !(getbufvar('%','win') =~ ' edit')
        bwipeout!
    endif
    let prevbnr = getbufvar('%','prevbnr') 
    if !bufexists(prevbnr)
        let prevbnr = -1
    endif
    if bufnr('%') != prevbnr
        exe g:easybuffer_keep.prevbnr.'buffer'
    endif
    if prevbnr != a:bnr
        exe ''.a:bnr.'buffer'
    endif
endfunction

function! s:DelBuffer()
    if g:easybuffer_show_header
        let header = 2
    else
        let header = 0
    endif
    if line('.') > header
        let bnr = s:BufNr(line('.'))
        if bufexists(bnr)
            if !getbufvar(bnr, "&modified")
                exe ''.bnr.'bdelete'
                setlocal modifiable
                normal! dd
                setlocal nomodifiable
                call s:RemoveBuffer(bnr)
                echo ''
            else
                echo "buffer is modified"
            endif
        else
            echo "no such buffer"
        endif
    endif
endfunction

function! s:WipeoutBuffer()
    if g:easybuffer_show_header
        let header = 2
    else
        let header = 0
    endif
    if line('.') > header
        let bnr = s:BufNr(line('.'))
        if bufexists(bnr)
            exe ''.bnr.'bwipeout!'
            setlocal modifiable
            normal! dd
            setlocal nomodifiable
            call s:RemoveBuffer(bnr)
            echo ''
        else
            echo "no such buffer"
        endif
    endif
endfunction
" }}}

" utility functions {{{
function! s:BufNr(line)
    if g:easybuffer_show_header
        let header = 2
    else
        let header = 0
    endif
    let bnrlist = getbufvar('%','bnrlist')
    return bnrlist[a:line - header - 1]
endfunction

function! s:RemoveValue(dict,bnr)
    let dict = getbufvar('%',a:dict)
    for k in keys(dict)
        if dict[k] == a:bnr
            call remove(dict,k)
            break
        endif
    endfor
    call setbufvar('%',a:dict,dict)
endfunction

function! s:RemoveBuffer(bnr)
    if g:easybuffer_use_sequence
        call s:RemoveValue('bnrseqdict',a:bnr)
    endif
    call s:RemoveValue('keydict',a:bnr)
    let bnrlist = getbufvar('%','bnrlist')
    let i = 0
    for bi in bnrlist
        if bi == a:bnr
            call remove(bnrlist,i)
            break
        endif
        let i += 1
    endfor
    call setbufvar('%','bnrlist',bnrlist)
endfunction

function! s:GotoBuffer(bnr)
    if g:easybuffer_show_header
        let header = 2
    else
        let header = 0
    endif
    if line('$') > header
        let bnrlist = getbufvar('%','bnrlist')
        let ind = index(bnrlist,a:bnr)
        if ind != -1
            let i = header + 1 + ind
            exe 'normal! '.i.'G0^'
        endif
        echo ''
    endif
endfunction

function! s:ClearInput()
    match none
    call setbufvar('%','inputn','')
    call setbufvar('%','inputk','')
endfunction

function! s:HighlightNotMatchedBnr(bnrs)
    let p = ''
    let i = 0
    if len(a:bnrs) == 0 | return | endif
    if g:easybuffer_use_sequence
        let bnrseqdict = getbufvar('%','bnrseqdict')
    endif
    for bnr in a:bnrs
        if i != 0 | let p .= '\|' | endif
        if g:easybuffer_use_sequence
            for i in keys(bnrseqdict)
                if bnrseqdict[i] == bnr
                    let p .= ''.i
                    break
                endif
            endfor
        else
            let p .= ''.bnr
        endif
        let i += 1
    endfor
    let p = '/^\s*\('.p.'\)\s.*$/'
    exe 'match EasyBufferDisabled '.p
endfunction
" }}}

" key press related functions {{{
function! s:EnterPressed()
    let input = getbufvar('%','inputn')
    let inputk = getbufvar('%','inputk')
    if g:easybuffer_show_header
        let header = 2
    else
        let header = 0
    endif
    if !empty(inputk)
        let inputkl = tolower(inputk)
        let keydict = getbufvar('%','keydict')
        for k in keys(keydict)
            if k == inputkl
                if char2nr(inputk[len(inputk)-1]) == char2nr(inputkl[len(inputkl)-1])
                    match none
                    call s:SelectBuf(keydict[k])
                else
                    let inputk = ''
                    match none
                    call setbufvar('%','inputk',inputk)
                    call setbufvar('%','inputn',inputk)
                    call s:GotoBuffer(keydict[k])
                endif
                return
            endif
        endfor
        let inputk = ''
        match none
        call setbufvar('%','inputk',inputk)
        call setbufvar('%','inputn','')
    elseif !empty(input)
        let bnrlist = getbufvar('%','bnrlist')
        if g:easybuffer_use_sequence
            let bnrseqdict = getbufvar('%','bnrseqdict')
            for i in keys(bnrseqdict)
                if (''.i) == input
                    match none
                    call s:SelectBuf(bnrseqdict[i])
                    return
                endif
            endfor
        else
            for bnr in bnrlist
                if (''.bnr) == input
                    match none
                    call s:SelectBuf(bnr)
                    return
                endif
            endfor
        endif
        let input = ''
        match none
        call setbufvar('%','inputn',input)
        call setbufvar('%','inputk','')
    elseif line('.') > header
        let bnr = s:BufNr(line('.'))
        match none
        call s:SelectBuf(bnr)
    else
        match none
        call setbufvar('%','inputn','')
        call setbufvar('%','inputk','')
    endif
endfunction

function! s:KeyPressed(k)
    let input = getbufvar('%','inputk').a:k
    let inputl = tolower(input)
    let keydict = getbufvar('%','keydict')
    let matches = 0
    let matchedk = 0
    let notmatchedbnr = []
    for k in keys(keydict)
        if match(k,'^'.inputl) != -1
            let matches += 1
            let matchedk = k
        else
            call add(notmatchedbnr,keydict[k])
        endif
    endfor
    if matches == 1
        if char2nr(input[len(input)-1]) == char2nr(inputl[len(inputl)-1])
            match none
            call s:SelectBuf(keydict[matchedk])
        else
            let input = ''
            match none
            call setbufvar('%','inputk',input)
            call setbufvar('%','inputn',input)
            call s:GotoBuffer(keydict[matchedk])
        endif
        return
    elseif matches == 0
        echo 'invalid key: '.input
        let input = ''
    endif
    if len(input) > 0
        call s:HighlightNotMatchedBnr(notmatchedbnr)
        echo 'select key: '.input
    else
        match none
    endif
    call setbufvar('%','inputk',input)
    call setbufvar('%','inputn','')
endfunction

function! s:NumberPressed(n)
    let input = getbufvar('%','inputn').a:n
    let bnrlist = getbufvar('%','bnrlist')
    let matches = 0
    let matchedbnr = 0
    let notmatchedbnr = []
    if g:easybuffer_use_sequence
        let bnrseqdict = getbufvar('%','bnrseqdict')
        for i in keys(bnrseqdict)
            if match(''.i,'^'.input) != -1
                let matches += 1
                let matchedbnr = bnrseqdict[i]
            else
                call add(notmatchedbnr,bnrseqdict[i])
            endif
        endfor
    else
        for bnr in bnrlist
            if match(''.bnr,'^'.input) != -1
                let matches += 1
                let matchedbnr = bnr
            else
                call add(notmatchedbnr,bnr)
            endif
        endfor
    endif
    if matches == 1
        match none
        call s:SelectBuf(matchedbnr)
        return
    elseif matches == 0
        if g:easybuffer_use_sequence
            echo 'invalid seqnr: '.input
        else
            echo 'invalid bufnr: '.input
        endif
        let input = ''
    endif
    if len(input) > 0
        call s:HighlightNotMatchedBnr(notmatchedbnr)
        if g:easybuffer_use_sequence
            echo 'select seqnr: '.input
        else
            echo 'select bufnr: '.input
        endif
    else
        match none
    endif
    call setbufvar('%','inputn',input)
    call setbufvar('%','inputk','')
endfunction
" }}}

" easybuffer related functions {{{
function! s:ListBuffers(unlisted)
    let bnrlist = filter(range(1,bufnr("$")), "bufexists(v:val) && getbufvar(v:val,'&filetype') != 'easybuffer'")
    if !a:unlisted
        let bnrlist = filter(bnrlist, "buflisted(v:val)")
    endif
    let keydict = {}
    call setbufvar('%','bnrlist',bnrlist)
    let prevbnr = getbufvar('%','prevbnr') 
    let maxftwidth = 10
    let bnrseqdict = {}
    for bnr in bnrlist
        if len(getbufvar(bnr,'&filetype')) > maxftwidth
            let maxftwidth = len(getbufvar(bnr,'&filetype'))
        endif
    endfor
    if g:easybuffer_show_header
        call setline(1, 'easybuffer - buffer list (press key or bufnr to select the buffer, press d to delete or D to wipeout buffer)')
        if g:easybuffer_use_sequence
            let numtitle = '<SeqNr>'
        else
            let numtitle = '<BufNr>'
        endif
        call append(1,numtitle.' <Key>  <Mode>  '.s:StrCenter('<Filetype>',maxftwidth).'  <BufName>')
    endif
    let i = 1
    for bnr in bnrlist
        let key = ''
        let keyok = 0
        while !keyok 
            for k in g:easybuffer_chars
                if !has_key(keydict, key.k)
                    let key = key.k
                    let keyok = 1
                    break
                endif
            endfor
            if !keyok
                if len(key) == 0
                    let key = g:easybuffer_chars[0]
                else
                    let kb = key[len(key)-1]
                    let kn = 0
                    for k in g:easybuffer_chars
                        if kn
                            let key = key[:-2].k
                            let kn = 0
                            break
                        endif
                        if k == kb
                            let kn = 1
                        endif
                    endfor
                    if kn 
                        let key .= g:easybuffer_chars[0]
                    endif
                endif
            endif
        endwhile
        let keydict[key] = bnr
        let key = s:StrCenter(key,5)
        let mode = ''
        let bufmodified = getbufvar(bnr, "&mod")
        if !buflisted(bnr)
            let mode .= 'u'
        endif
        if bufwinnr('%') == bufwinnr(bnr)
            let mode .= '%'
        elseif bufnr('#') == bnr
            let mode .= '#'
        endif
        if winbufnr(bufwinnr(bnr)) == bnr
            let mode .= 'a'
        else
            let mode .= 'h'
        endif
        if !getbufvar(bnr, "&modifiable")
            let mode .= '-'
        elseif getbufvar(bnr, "&readonly")
            let mode .= '='
        endif
        if getbufvar(bnr, "&modified")
            let mode .= '+'
        endif
        let mode = ' '.s:StrRight(mode,5)
        let bname = bufname(bnr)
        if len(bname) > 0
            let bname = eval(g:easybuffer_bufname)
            let bufft = getbufvar(bnr,'&filetype')
            if empty(bufft) | let bufft = '-' | endif
            let bufft = s:StrCenter(bufft,maxftwidth)
        else
            let bname = '[No Name]'
            let bufft = s:StrCenter('-',maxftwidth)
        endif
        if g:easybuffer_use_sequence
            let bnrs = s:StrCenter(''.i,7)
            let bnrseqdict[i] = bnr
        else
            let bnrs = s:StrCenter(''.bnr,7)
        endif
        call append(line('$'),bnrs.' '.key.'  '.mode.'  '.bufft.'  '.bname)
        if bnr == prevbnr
            call cursor(line('$'),0)
        endif
        let i += 1
    endfor
    if !g:easybuffer_show_header
        let cursor = getpos(".")
        normal! gg"_dd
        let cursor[1] = cursor[1] - 1
        call setpos('.', cursor)
    endif
    call setbufvar('%','keydict',keydict)
    if g:easybuffer_use_sequence
        call setbufvar('%','bnrseqdict',bnrseqdict)
    endif
    match none
endfunction

function! s:Refresh()
    setlocal modifiable
    silent! normal! ggdGG
    call s:ListBuffers(getbufvar('%','unlisted'))
    setlocal nomodifiable
endfunction
" }}}

" global functions {{{
function! easybuffer#OpenEasyBuffer(bang,win)
    let prevbnr = bufnr('%')
    let winnr = bufwinnr('^easybuffer$')
    let unlisted = 0
    if a:bang == '!'
        let unlisted = 1
    endif
    if winnr < 0
        "set hidden allows unsaved buffers
        set hidden 
        execute a:win . ' easybuffer'
        setlocal filetype=easybuffer buftype=nofile bufhidden=wipe nobuflisted noswapfile nonumber nowrap
        call setbufvar('%','prevbnr',prevbnr)
        call setbufvar('%','win',a:win)
        call setbufvar('%','unlisted',unlisted)
        if g:easybuffer_use_zoomwintab && g:zoomwintab_loaded
            call setbufvar('%','zoomwintab',gettabvar(tabpagenr(),'zoomwintab') == '')
        endif
        call s:ListBuffers(unlisted)
        setlocal nomodifiable
        if g:easybuffer_cursorline
            setlocal cursorline
        endif
        nnoremap <silent> <buffer> <Esc> :call <SID>ClearInput()<CR>
        nnoremap <silent> <buffer> d :call <SID>DelBuffer()<CR>
        nnoremap <silent> <buffer> D :call <SID>WipeoutBuffer()<CR>
        nnoremap <silent> <buffer> R :call <SID>Refresh()<CR>
        nnoremap <silent> <buffer> q :call easybuffer#CloseEasyBuffer()<CR>
        nnoremap <silent> <buffer> <Enter> :call <SID>EnterPressed()<CR>
        for i in range(10)
            exe 'nnoremap <silent> <buffer> '.i." :call <SID>NumberPressed(".i.")<CR>"
        endfor
        for k in g:easybuffer_chars
            exe 'nnoremap <silent> <buffer> '.k." :call <SID>KeyPressed('".k."')<CR>"
            exe 'nnoremap <silent> <buffer> '.toupper(k)." :call <SID>KeyPressed('".toupper(k)."')<CR>"
        endfor
    else
        exe g:easybuffer_keep.winnr . 'wincmd w'
        call setbufvar('%','win',a:win)
        call setbufvar('%','unlisted',unlisted)
        call s:Refresh()
    endif
    if g:easybuffer_use_zoomwintab && g:zoomwintab_loaded && b:zoomwintab
        silent! ZoomWinTabIn
        let pos = getpos('.')
        exe 'normal! '.line('$').'z^'
        call setpos('.',pos)
    endif
endfunction

function! easybuffer#CloseEasyBuffer() 
    if g:easybuffer_use_zoomwintab && g:zoomwintab_loaded && b:zoomwintab
        silent! ZoomWinTabOut
    endif
    let prevbnr = getbufvar('%','prevbnr')
    if !bufexists(prevbnr)
        let prevbnr = -1
    endif
    if bufname(prevbnr) == 'easybuffer'
        let prevbnr = -1
    endif
    if prevbnr == -1
        if winnr("$") > 1
            close
        else
            echomsg "Cannot close last window"
        endif
    else
        call s:SelectBuf(prevbnr)
    endif
endfunction

function! easybuffer#ToggleEasyBuffer(bang)
    let winnr = bufwinnr('^easybuffer$')
    if winnr == -1
        exe 'call easybuffer#OpenEasyBuffer'.g:easybuffer_toggle_position.'(a:bang)'
    else
        call easybuffer#CloseEasyBuffer()
    endif
endfunction

function! easybuffer#OpenEasyBufferCurrent(bang)
    call easybuffer#OpenEasyBuffer(a:bang,g:easybuffer_keep.'edit')
endfunction

function! easybuffer#OpenEasyBufferHorizontal(bang)
    exe "call easybuffer#OpenEasyBuffer(a:bang,g:easybuffer_keep.(".g:easybuffer_horizontal_height.").'sp')"
endfunction

function! easybuffer#OpenEasyBufferHorizontalBelow(bang)
    exe "call easybuffer#OpenEasyBuffer(a:bang,g:easybuffer_keep.'belowright '.(".g:easybuffer_horizontal_height.").'sp')"
endfunction

function! easybuffer#OpenEasyBufferVertical(bang)
    exe "call easybuffer#OpenEasyBuffer(a:bang,g:easybuffer_keep.(".g:easybuffer_vertical_width.").'vs')"
endfunction

function! easybuffer#OpenEasyBufferVerticalRight(bang)
    exe "call easybuffer#OpenEasyBuffer(a:bang,g:easybuffer_keep.'belowright '.(".g:easybuffer_vertical_width.").'vs')"
endfunction

" }}}
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
