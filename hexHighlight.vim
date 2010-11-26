"gvim plugin for highlighting hex codes to help with tweaking colors
"Last Change: 2010 Jan 30
"Maintainer: Yuri Feldman <yuri@tbqh.net>
"License: WTFPL - Do What The Fuck You Want To Public License.
"Email me if you'd like.
let s:HexColored = 0
let s:HexColors = []

map <Leader><F2> :call HexHighlight()<Return>
function! HexHighlight()
    if has("gui_running")
        if s:HexColored == 0
            let hexGroup = 4
            let lineNumber = 0
            while lineNumber <= line("$")
                let currentLine = getline(lineNumber)
                let hexLineMatch = 1

                while match(currentLine, '#\x\{6}\|#\x\{3}', 0, hexLineMatch) != -1
                    let hexMatch = matchstr(currentLine, '#\x\{6}\|#\x\{3}', 0, hexLineMatch)

                    if strlen(hexMatch) == 4
                      let rPart = strpart(hexMatch, 1, 1)
                      let gPart = strpart(hexMatch, 2, 1)
                      let bPart = strpart(hexMatch, 3, 1)
                      let rPart = str2nr(rPart.rPart, 16)
                      let gPart = str2nr(gPart.gPart, 16)
                      let bPart = str2nr(bPart.bPart, 16)
                    else
                      let rPart = str2nr(strpart(hexMatch, 1, 2), 16)
                      let gPart = str2nr(strpart(hexMatch, 3, 2), 16)
                      let bPart = str2nr(strpart(hexMatch, 5, 2), 16)
                    end

                    if rPart > 127 || gPart > 127 || bPart > 127
                      let hexComplement = "#000"
                    else
                      let hexComplement = "#FFF"
                    end

                    exe 'hi hexColor'.hexGroup.' guifg='.hexComplement.' guibg='.hexMatch
                    exe 'let m = matchadd("hexColor'.hexGroup.'", "'.hexMatch.'", 25, '.hexGroup.')'
                    let s:HexColors += ['hexColor'.hexGroup]
                    let hexGroup += 1
                    let hexLineMatch += 1
                endwhile

                let lineNumber += 1
            endwhile
            unlet lineNumber hexGroup
            let s:HexColored = 1
            echo "Highlighting hex colors..."
        elseif s:HexColored == 1
            for hexColor in s:HexColors
                exe 'highlight clear '.hexColor
            endfor
            call clearmatches()
            let s:HexColored = 0
            echo "Unhighlighting hex colors..."
        endif
    else
        echo "hexHighlight only works with a graphical version of vim"
    endif
endfunction
