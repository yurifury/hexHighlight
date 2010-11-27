"gvim plugin for highlighting hex codes to help with tweaking colors
"Last Change: 2010 Nov 26
"Maintainer: Yuri Feldman <yuri@tbqh.net>
"License: WTFPL - Do What The Fuck You Want To Public License.
"Email me if you'd like.
if exists('g:loaded_hexHighlight') || v:version < 700
    finish
endif
let s:HexColored = 0
let s:HexColors = []

nnoremap <Plug>HexHighlightToggle :<C-u>call <SID>HexHighlightToggle()<CR>
if ! hasmapto('<Plug>HexHighlightToggle', 'n')
    nmap <Leader><F2> <Plug>HexHighlightToggle
endif
nnoremap <Plug>HexHighlightRefresh :<C-u>call <SID>HexHighlightRefresh()<CR>
if ! hasmapto('<Plug>HexHighlightRefresh', 'n')
    nmap <Leader>[ <Plug>HexHighlightRefresh
endif

function! s:HexHighlightRefresh()
    if ! has("gui_running")
        echo "hexHighlight only works with a graphical version of vim"
        return 0
    endif
    if s:HexColored == 0
        let s:HexColored = s:HexColorize()
        echo "Highlighting hex colors"
    elseif s:HexColored == 1
        call s:HexClear()
        let s:HexColored = s:HexColorize()
        echo "Refreshing hex colors"
    endif
endfunction

function! s:HexHighlightToggle()
    if ! has("gui_running")
        echo "hexHighlight only works with a graphical version of vim"
        return 0
    endif
    if s:HexColored == 0
        let s:HexColored = s:HexColorize()
        echo "Highlighting hex colors"
    elseif s:HexColored == 1
        let s:HexColored = s:HexClear()
        echo "Unhighlighting hex colors"
    endif
endfunction

function! s:HexClear()
    for hexColor in s:HexColors
        exe 'highlight clear '.hexColor
    endfor
    call clearmatches()
    return 0
endfunction

function! s:HexColorize()
    let hexGroup = 4
    let lineNumber = 0
    while lineNumber <= line("$")
        let currentLine = getline(lineNumber)
        let hexLineMatch = 1

        while match(currentLine, '#\x\{6}\|#\x\{3}', 0, hexLineMatch) != -1
            let hexMatch = matchstr(currentLine, '#\x\{6}\|#\x\{3}', 0, hexLineMatch)

            let hexColor=hexMatch
            if (strlen(hexMatch) == 4)
                let hexColor = '#' . substitute(strpart(hexMatch, 1), '.', '&&', 'g')
            endif

            let rPart = str2nr(strpart(hexColor, 1, 2), 16)
            let gPart = str2nr(strpart(hexColor, 3, 2), 16)
            let bPart = str2nr(strpart(hexColor, 5, 2), 16)

            if rPart > 127 || gPart > 127 || bPart > 127
                let hexComplement = "#000000"
            else
                let hexComplement = "#FFFFFF"
            end

            exe 'hi hexColor'.hexGroup.' guifg='.hexComplement.' guibg='.hexColor
            exe 'let m = matchadd("hexColor'.hexGroup.'", "'.hexColor.'", 25, '.hexGroup.')'
            let s:HexColors += ['hexColor'.hexGroup]
            let hexGroup += 1
            let hexLineMatch += 1
        endwhile

        let lineNumber += 1
    endwhile
    unlet lineNumber hexGroup
    return 1
endfunction
