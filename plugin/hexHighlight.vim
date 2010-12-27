" ============================================================================
" File:        hexHighlight.vim
" Description: gvim plugin that provides context highlighting for hex codes
" Maintainer:  Yuri Feldman <yuri@tbqh.net>
" Version:     2
" Last Change: 27th December, 2010
" License:     WTFPL - Do What The Fuck You Want To Public License.
"
" ============================================================================

" Section: Script init {{{1
"if exists('loaded_hexHighlight')
    "finish
"endif

if v:version < 700
    echoerr "hexHighlight requires vim >= 7. Download it!"
    finish
endif
let loaded_hexHighlight = 1

let g:HexVisibleText = 1
let s:HexColored = 0
let s:ColorsDict = {}

" Section: Script functions {{{1
" Function: s:HexHighlightToggle {{{2
function! HexHighlightToggle()
    if !has("gui_running")
        echo "hexHighlight only works with a graphical version of vim"
        return
    endif

    if s:HexColored == 0
        call s:PopulateColorsDict()
        call s:HighlightDict()
        let s:HexColored = 1
        echo "Highlighting hex colors"
    elseif s:HexColored == 1
        call s:HexClear()
        let s:HexColored = 0
        echo "Unhighlighting hex colors"
    endif
endfunction

" Function: s:HexClear {{{2
function! s:HexClear()
    for hexNum in keys(s:ColorsDict)
        exec 'highlight clear '.hexNum
    endfor
    call clearmatches()
endfunction

" Function: s:PopulateColorsDict {{{2
function! s:PopulateColorsDict()
    let lineNumber = 0
    while lineNumber <= line("$")
        let currentLine = getline(lineNumber)

        let hexLineMatch = 1
        while match(currentLine, '#\x\{6}', 0, hexLineMatch) != -1
            let hexColor = matchstr(currentLine, '#\x\{6}', 0, hexLineMatch)

            let hexNum = strpart(hexColor, 1)
            if !has_key(s:ColorsDict, hexNum)
                let hexComplement = '#' . s:CalcVisibleForeground(hexNum)
                let s:ColorsDict[hexNum] = {'hexColor': hexColor, 'hexComplement': hexComplement}
            endif

            let hexLineMatch += 1
        endwhile

        let hexLineMatch = 1
        while match(currentLine, '#\x\{3}', 0, hexLineMatch) != -1
            let shortHexColor = matchstr(currentLine, '#\x\{3}', 0, hexLineMatch)
            let shortHexNum = strpart(shortHexColor, 1)

            let hexNum = substitute(shortHexNum, '.', '&&', 'g')
            let hexColor = '#' . hexNum
            if !has_key(s:ColorsDict, shortHexNum)
                let hexComplement = '#' . s:CalcVisibleForeground(hexNum)
                echo shortHexNum
                let s:ColorsDict[shortHexNum] = {'hexColor': hexColor, 'hexComplement': hexComplement}
            endif

            let hexLineMatch += 1
        endwhile

        let lineNumber += 1
    endwhile
endfunction

" Function: s:HighlightDict {{{2
function! s:HighlightDict()
    for hexNum in keys(s:ColorsDict)
        let hexColor = s:ColorsDict[hexNum]['hexColor']
        let hexComplement = s:ColorsDict[hexNum]['hexComplement']
        "echo hexNum
        "echo hexColor

        if g:HexVisibleText
            exec 'hi ' . hexNum . ' guibg=' . hexColor . ' guifg=' . hexComplement
        else
            exec 'hi ' . hexNum . ' guibg=' . hexColor . ' guifg=' . hexColor
        endif

        let m = matchadd(hexNum, hexColor)
    endfor
endfunction

" Function: s:CalcVisibleForeground(color) {{{2
" figures out whether a white or black color is contrasting to color
" Args:
"   -color: the color to figure the foreground to
function! s:CalcVisibleForeground(color)
    let rPart = str2nr(strpart(a:color, 0, 2), 16)
    let gPart = str2nr(strpart(a:color, 2, 2), 16)
    let bPart = str2nr(strpart(a:color, 4, 2), 16)

    if rPart > 127 || gPart > 127 || bPart > 127
        return '000000'
    else
        return 'FFFFFF'
    end
endfunction

" vim: set foldmethod=marker :
