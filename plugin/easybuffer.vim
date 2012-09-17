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

if !exists("g:easybuffer_chars")
    let g:easybuffer_chars = ['a','s','f','w','e','z','x','c','v']
endif

if !exists("g:easybuffer_bufname")
    let g:easybuffer_bufname = "bname"
endif

if !exists("g:easybuffer_cursorline")
    let g:easybuffer_cursorline = 1
endif

" check for available command
let g:easybuffer_keep = ''
if exists(":keepalt")
    let g:easybuffer_keep .= 'keepalt '
endif

if exists(":keepjumps")
    let g:easybuffer_keep .= 'keepjumps '
endif

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

function! s:SelectBuf(bnr)
    if !(getbufvar('%','win') =~ ' edit')
        bwipeout!
    endif
    let prevbnr = getbufvar('%','prevbnr') 
    if bufnr('%') != prevbnr
        exe g:easybuffer_keep.prevbnr.'buffer'
    endif
    if prevbnr != a:bnr
        exe ''.a:bnr.'buffer'
    endif
endfunction

function! s:DelBuffer()
    if line('.') > 2
        let bnr = str2nr(split(getline('.'),'\s\+')[0])
        if bufexists(bnr)
            if !getbufvar(bnr, "&modified")
                exe ''.bnr.'bdelete'
                setlocal modifiable
                normal! dd
                setlocal nomodifiable
            else
                echo "buffer is modified"
            endif
        else
            echo "no such buffer"
        endif
    endif
endfunction

function! s:WipeoutBuffer()
    if line('.') > 2
        let bnr = str2nr(split(getline('.'),'\s\+')[0])
        if bufexists(bnr)
            exe ''.bnr.'bwipeout!'
            setlocal modifiable
            normal! dd
            setlocal nomodifiable
        else
            echo "no such buffer"
        endif
    endif
endfunction

function! s:GotoBuffer(bnr)
    if line('$') > 2
        for i in range(3,line('$'))
            let bnr = str2nr(split(getline(i),'\s\+')[0])
            if bnr == a:bnr
                exe 'normal! '.i.'G0^'
                break
            endif
        endfor
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
    for bnr in a:bnrs
        if i != 0 | let p .= '\|' | endif
        let p .= ''.bnr
        let i += 1
    endfor
    let p = '/^\s*\('.p.'\)\s.*$/'
    exe 'match EasyBufferDisabled '.p
endfunction

function! s:EnterPressed()
    let input = getbufvar('%','inputn')
    let inputk = getbufvar('%','inputk')
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
        for bnr in bnrlist
            if (''.bnr) == input
                match none
                call s:SelectBuf(bnr)
                return
            endif
        endfor
        let input = ''
        match none
        call setbufvar('%','inputn',input)
        call setbufvar('%','inputk','')
    elseif line('.') > 2
        let bnr = str2nr(split(getline('.'),'\s\+')[0])
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
    for bnr in bnrlist
        if match(''.bnr,'^'.input) != -1
            let matches += 1
            let matchedbnr = bnr
        else
            call add(notmatchedbnr,bnr)
        endif
    endfor
    if matches == 1
        match none
        call s:SelectBuf(matchedbnr)
        return
    elseif matches == 0
        let input = ''
    endif
    if len(input) > 0
        call s:HighlightNotMatchedBnr(notmatchedbnr)
        echo 'select bufnr: '.input
    else
        match none
    endif
    call setbufvar('%','inputn',input)
    call setbufvar('%','inputk','')
endfunction

function! s:ListBuffers(unlisted)
    call setline(1, 'easybuffer - buffer list (press key or bufnr to select the buffer, press d to delete or D to wipeout buffer)')
    let bnrlist = filter(range(1,bufnr("$")), "bufexists(v:val) && getbufvar(v:val,'&filetype') != 'easybuffer'")
    if !a:unlisted
        let bnrlist = filter(bnrlist, "buflisted(v:val)")
    endif
    let keydict = {}
    call setbufvar('%','bnrlist',bnrlist)
    let prevbnr = getbufvar('%','prevbnr') 
    let maxftwidth = 10
    for bnr in bnrlist
        if len(getbufvar(bnr,'&filetype')) > maxftwidth
            let maxftwidth = len(getbufvar(bnr,'&filetype'))
        endif
    endfor
    call append(1,'<BufNr> <Key>  <Mode>  '.s:StrCenter('<Filetype>',maxftwidth).'  <BufName>')
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
        let bnrs = s:StrCenter(''.bnr,7)
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
        call append(line('$'),bnrs.' '.key.'  '.mode.'  '.bufft.'  '.bname)
        if bnr == prevbnr
            call cursor(line('$'),0)
        endif
    endfor
    call setbufvar('%','keydict',keydict)
    match none
endfunction

function! s:Refresh()
    setlocal modifiable
    silent! normal! ggdGG
    call s:ListBuffers(getbufvar('%','unlisted'))
    setlocal nomodifiable
endfunction

function! s:OpenEasyBuffer(bang,win)
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
        setlocal filetype=easybuffer buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
        call setbufvar('%','prevbnr',prevbnr)
        call setbufvar('%','win',a:win)
        call setbufvar('%','unlisted',unlisted)
        call s:ListBuffers(unlisted)
        setlocal nomodifiable
        if g:easybuffer_cursorline
            setlocal cursorline
        endif
        nnoremap <silent> <buffer> <Esc> :call <SID>ClearInput()<CR>
        nnoremap <silent> <buffer> d :call <SID>DelBuffer()<CR>
        nnoremap <silent> <buffer> D :call <SID>WipeoutBuffer()<CR>
        nnoremap <silent> <buffer> R :call <SID>Refresh()<CR>
        nnoremap <silent> <buffer> q :call <SID>CloseEasyBuffer()<CR>
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
endfunction

function! s:CloseEasyBuffer() 
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

function! s:ToggleEasyBuffer()
    let winnr = bufwinnr('^easybuffer$')
    if winnr == -1
        call s:OpenEasyBuffer('<bang>',g:easybuffer_keep.'edit')
    else
        call s:CloseEasyBuffer()
    endif
endfunction

command! -bang EasyBuffer call <SID>OpenEasyBuffer('<bang>',g:easybuffer_keep.'edit')
command! -bang EasyBufferClose call <SID>CloseEasyBuffer()
command! -bang EasyBufferToggle call <SID>ToggleEasyBuffer()
command! -bang EasyBufferHorizontal call <SID>OpenEasyBuffer('<bang>',g:easybuffer_keep.(&lines/2).'sp')
command! -bang EasyBufferHorizontalBelow call <SID>OpenEasyBuffer('<bang>',g:easybuffer_keep.'belowright '.(&lines/2).'sp')
command! -bang EasyBufferVertical call <SID>OpenEasyBuffer('<bang>',g:easybuffer_keep.(&columns/2).'vs')
command! -bang EasyBufferVerticalRight call <SID>OpenEasyBuffer('<bang>',g:easybuffer_keep.'belowright '.(&columns/2).'vs')

let &cpo = s:save_cpo
unlet s:save_cpo

