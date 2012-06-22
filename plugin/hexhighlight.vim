" ============================================================================
" File:        hexhighlight.vim
" Description: VIM plugin that provides highlighting for colorcodes
" Maintainer:  Thomas Gläßle
" URL:         https://github.com/thomas-glaessle/hexHighlight
" Original:    Yuri Feldman <yuri@tbqh.net>
"              https://github.com/yurifury  and
"              https://github.com/vesan/hexHighlight
" Version:     2.1
" Last Change: 18. January, 2012
" License:     WTFPL - Do What The Fuck You Want To Public License.
"
" ============================================================================

if v:version < 700
    echoerr 'hexhighlight requires VIM 7'
    finish
endif


" Section: Mappings {{{1
" Subsection: Plugins {{{2
noremap <Plug>ToggleHexHighlight    :<C-u>call <SID>ToggleHexHighlight()<CR>
noremap <Plug>ToggleSchemeHighlight :<C-u>call <SID>ToggleSchemeHighlight()<CR>

" Subsection: KeyMappings {{{2
nmap <F2>           <Plug>ToggleHexHighlight
nmap <leader><F2>   <Plug>ToggleSchemeHighlight
" 2}}}

" Section: Initialize static variables {{{1
function! s:Init(Rgb2Cterm, Cterm2Rgb)
    let s:Flags = 1     " 1 = TextVisible
    let s:State = 0     " Global toggle state
    let s:Color = {}    " Cache, contains matching cterm/hex-codes
    let s:Group = {}    " Cache, contains information about highlight groups

    if a:Rgb2Cterm != '' && executable(a:Rgb2Cterm)
        let s:Rgb2Cterm = a:Rgb2Cterm
    else
        let s:Rgb2Cterm = ''
    endif
    if a:Cterm2Rgb && executable(a:Cterm2Rgb)
        let s:Cterm2Rgb = a:Cterm2Rgb
    else
        let s:Cterm2Rgb = ''
    endif
endfunction

" Path to rgb2cterm script (pass 0 if not existing)
call s:Init(expand('<sfile>:h').'/../script/rgb2cterm', expand('<sfile>:h').'/../script/cterm2rgb')


" Section: Implementation {{{1
" Subsection: Control functions {{{2
function! s:ToggleHexHighlight()
    if !has('gui_running') && s:Rgb2Cterm == ''
        echo 'hexhighlight needs Rgb2Cterm in terminal VIM.'
        return
    endif
    if and(s:State, 1)
        echo 'Unhighlighting color codes'
        call s:Unhighlight('^hex')
    else
        echo 'Highlighting color codes'
        call s:HexHighlight()
    endif
    let s:State = xor(s:State, 1)
endfunction

function! s:ToggleSchemeHighlight()
    if and(s:State, 2)
        echo 'Unhighlighting color scheme'
        call s:Unhighlight('^mixed')
    else
        echo 'Highlighting color scheme'
        call s:SchemeHighlight()
    endif
    let s:State = xor(s:State, 2)
endfunction

" Subsection: HexHighlight Workhorse {{{2
function! s:HexHighlight()
    " Check if this is a gui / terminal process
    let l:gui = has('gui_running')
    if l:gui
        let l:variant = 'hex'
    else
        let l:variant = 'cterm'
    endif

    " Parse current file
    for l:lineNo in range(1, line('$'))
        let l:line = getline(l:lineNo)

        let l:start = match(l:line, '#\v(\x{6}|\x{3})')
        while l:start != -1
            " cut the leading sharp-sign ('#')
            let l:match = matchstr(l:line, '\v(\x{6}|\x{3})', l:start + 1)
            let l:hexcode = l:match

            " convert 3-digit-codes #f81 to 6-digit-codes #ff8811
            if (strlen(l:hexcode) == 3)
                let l:hexcode = substitute(l:hexcode, '.', '&&', 'g')
            endif

            " Get FG/BG Colors
            let l:bg = s:CacheColor(l:hexcode, 'hex', l:variant)[l:variant]
            let l:fg = l:bg

            " make foreground visible if s:Flags & 1
            if and(s:Flags, 1)
                if and(str2nr(l:hexcode, 16), 0x808080)
                    let l:fg = '000000'
                else
                    let l:fg = 'FFFFFF'
                end
                let l:fg = s:CacheColor(l:fg, 'hex', l:variant)[l:variant]
            endif
            let l:bgcolor = s:CacheColor(l:hexcode, 'hex', l:variant)

            " highlight the hex code
            let l:group = s:ColorGroup(l:match, 'hex')
            if l:gui
                exe 'highlight '.l:group['name'].' guifg=#'.l:fg.' guibg=#'.l:bg
            else
                exe 'highlight '.l:group['name'].' ctermfg='.l:fg.' ctermbg='.l:bg
            endif
            let l:matchid = matchadd(l:group['name'], l:match)
            let l:group.matchid += [ l:matchid ]

            " find next match on current line
            let l:start = match(l:line, '#\v(\x{6}|\x{3})', l:start + 1)
        endwhile
    endfor
endfunction

" Subsection: Colorscheme-Highlightning {{{2
function! s:SchemeHighlight()
    let l:options  = []
    let l:options += [  'gui',   'guibg',   'guifg', 'guisp']
    let l:options += ['cterm', 'ctermbg', 'ctermfg']

    for l:lineNo in range(1, line('$'))
        let l:line = getline(l:lineNo)

        let l:match = matchlist(l:line, '\v^\s*(hi(ghlight)=\s*(\w+))\s*')
        if empty(l:match)
            continue
        endif
        let l:start = strlen(l:match[0])
        let l:pattern = l:match[1]
        let l:name = l:match[3]
        if l:name == 'clear'
            continue
        endif

        let l:group = s:ColorGroup(l:name, 'mixed')
        let l:cfg = {}

        " remember all known options 
        for l:option in l:options
            let l:index = matchend(l:line, l:option.'=', l:start)
            if l:index == -1
                let l:cfg[l:option] = 'NONE'
            else
                let l:cfg[l:option] = matchstr(l:line, '\v\S+', l:index)
            endif
        endfor

        " compose highlight command
        let l:hiCmd = 'highlight ' . l:group['name']
        for [l:key, l:value] in items(l:cfg)
            let l:hiCmd .= ' '.l:key.'='.l:value
        endfor

        " execute highlightning
        exec l:hiCmd
        let l:matchid = matchadd(l:group['name'], l:pattern.'.*') 
        let l:group.matchid += [ l:matchid ]
    endfor
endfunction

" Subsection: Group cache {{{2
function! s:ColorGroup(code, type)
    let l:key = a:type.a:code
    if !has_key(s:Group, l:key)
        let s:Group[l:key] = {'name': 'ColorCodeHighlight_'.l:key, 'matchid': []}
    endif
    return s:Group[l:key]
endfunction

function! s:Unhighlight(pattern)
    for l:key in keys(s:Group)
        if match(l:key, a:pattern) == -1
            continue
        endif
        let l:group = remove(s:Group, l:key)
        exe 'highlight clear '.l:group['name']
        for l:matchid in l:group['matchid']
            call matchdelete(l:matchid)
        endfor
    endfor
endfunction

" Subsection: Color caching {{{2
function! s:CacheColor(code, type, variant)
    let l:code = tolower(a:code)
    let l:key = a:type.l:code
    if !has_key(s:Color, l:key)
        let s:Color[l:key] = {}
        let s:Color[l:key][a:type] = l:code
    endif
    if a:variant != '' && !has_key(s:Color[l:key], a:variant)
        let s:Color[l:key][a:variant] = s:ConvertColor(s:Color[l:key][a:type], a:type, a:variant)
    endif
    return s:Color[l:key]
endfunction

" Subsection: Color conversion {{{2
function! s:ConvertColor(code, type, variant)
    if a:type == 'hex' && a:variant == 'cterm'
        return s:HexToCterm(a:code)
    elseif a:type == 'cterm' && a:variant == 'hex'
        return s:CtermToHex(a:code)
    else
        return a:code
    endif
endfunction

function! s:CtermToHex(ctermcode)
    return substitute(system(s:Cterm2Rgb.' '.a:ctermcode), '\n', '', '')
endfunction

function! s:HexToCterm(hexcode)
    return substitute(system(s:Rgb2Cterm.' '.a:hexcode), '\n', '', '')
endfunction
" 2}}}
" 1}}}

" vim: fdl=0 fdm=marker
