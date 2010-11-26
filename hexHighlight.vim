"gvim plugin for highlighting hex codes to help with tweaking colors
"Last Change: 2010 Jan 30
"Maintainer: Yuri Feldman <yuri@tbqh.net>
"License: WTFPL - Do What The Fuck You Want To Public License.
"Email me if you'd like.
if exists('g:loaded_hexHighlight') || v:version < 700
    finish
endif
let s:HexColored = 0
let s:HexColors = []

nnoremap <Plug>HexHighlightToggle :<C-u>call <SID>HexHighlight()<CR>
if ! hasmapto('<Plug>HexHighlightToggle', 'n')
    nmap <Leader><F2> <Plug>HexHighlightToggle
endif

function! s:HexHighlight()
    if has("gui_running")
        if s:HexColored == 0
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
            let s:HexColored = 1
            echo "Highlighting hex colors"
        elseif s:HexColored == 1
            for hexColor in s:HexColors
                exe 'highlight clear '.hexColor
            endfor
            call clearmatches()
            let s:HexColored = 0
            echo "Unhighlighting hex colors"
        endif
    else
        echo "hexHighlight only works with a graphical version of vim"
    endif
endfunction
