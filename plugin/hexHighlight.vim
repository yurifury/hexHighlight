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
if exists('loaded_hexHighlight')
    finish
endif

if v:version < 700
    echoerr "hexHighlight requires vim >= 7. Download it!"
    finish
endif
let loaded_hexHighlight = 1

let g:HexVisibleText = 1
let s:HexColored = 0
let s:ColorsDict = {}

"nnoremap <Plug>HexHighlightToggle :<C-u>call <SID>HexHighlightToggle()<CR>
"if ! hasmapto('<Plug>HexHighlightToggle', 'n')
    "nmap <Leader><F2> <Plug>HexHighlightToggle
"endif

"function! s:RefreshColorScheme()
    "exe 'w'
    "exe 'colorscheme ' . g:colors_name
"endfunction

"command! -nargs=? HHT         call s:HexHighlightToggle()

"function! s:HighlightHexCodes()
    "let lineNumber = 0
    "let matchno = 4
    "while lineNumber <= line("$")
        "let currentLine = getline(lineNumber)

        "if match(currentLine, '\v^\s*hi(light)?') != -1
            "let hiNameIndex = matchend(currentLine, '\v^\s*hi(light)?')
            "if hiNameIndex != -1
                "let hiNameMatch = matchstr(currentLine, '\v\w+', hiNameIndex)
            "endif

            "let guibgIndex = matchend(currentLine, 'guibg=')
            "if guibgIndex != -1
                "let guibgMatch = matchstr(currentLine, '\v\S+', guibgIndex)
            "else
                "let guibgMatch = 'NONE'
            "endif

            "let guifgIndex = matchend(currentLine, 'guifg=')
            "if guifgIndex != -1
                "let guifgMatch = matchstr(currentLine, '\v\S+', guifgIndex)
            "else
                "let guifgMatch = 'NONE'
            "endif

            "let guiIndex = matchend(currentLine, 'gui=')
            "if guiIndex != -1
                "let guiMatch = matchstr(currentLine, '\v\S+', guiIndex)
            "else
                "let guiMatch = 'none'
            "endif

            "let guispIndex = matchend(currentLine, 'guisp=')
            "if guispIndex != -1
                "let guispMatch = matchstr(currentLine, '\v\S+', guispIndex)
            "else
                "let guispMatch = 'NONE'
            "endif

            "if guifgMatch != 'NONE' || guibgMatch != 'NONE' || guiMatch != 'none' || guispMatch != 'NONE'
                "exec 'hi '.matchno.' guibg='.guibgMatch.' guifg='.guifgMatch.' gui='.guiMatch.' guisp='.guispMatch
                "let m = matchadd(matchno, hiNameMatch)
                "let matchno += 1
            "endif
        "endif
        "let lineNumber += 1
    "endwhile
"endfunction

"function! s:HighlightCTerms()
    "let s = clearmatches()

    "let lineNumber = 0
    "let matchno = 4
    "while lineNumber <= line("$")
        "let currentLine = getline(lineNumber)

        "if match(currentLine, '\v^\s*hi(light)?') != -1
            "let hiNameIndex = matchend(currentLine, '\v^\s*hi(light)?')
            "if hiNameIndex != -1
                "let hiNameMatch = matchstr(currentLine, '\v\w+', hiNameIndex)
            "endif

            "let ctermbgIndex = matchend(currentLine, 'ctermbg=')
            "if ctermbgIndex != -1 
                "let ctermbgMatch = matchstr(currentLine, '\v\S+', ctermbgIndex)
            "else
                "let ctermbgMatch = 'none'
            "endif

            "let ctermfgIndex = matchend(currentLine, 'ctermfg=')
            "if ctermfgIndex != -1
                "let ctermfgMatch = matchstr(currentLine, '\v\S+', ctermfgIndex)
            "else
                "let ctermfgMatch = 'none'
            "endif

            "let ctermIndex = matchend(currentLine, 'cterm=')
            "if ctermIndex != -1
                "let ctermMatch = matchstr(currentLine, '\v\S+', ctermIndex)
            "else
                "let ctermMatch = 'none'
            "endif

            "if ctermfgMatch != 'none' || ctermbgMatch != 'none' || ctermMatch != 'none'
                "exec 'hi '.matchno.' ctermbg='.ctermbgMatch.' ctermfg='.ctermfgMatch.' cterm='.ctermMatch
                "let m = matchadd(matchno, hiNameMatch)
                "let matchno += 1
            "endif
        "endif
        "let lineNumber += 1
    "endwhile
"endfunction

"function! s:HexHighlightRefresh()
    "if ! has("gui_running")
        "echo "hexHighlight only works with a graphical version of vim"
        "return 0
    "endif
    "if s:HexColored == 0
        "let s:HexColored = s:HexColorize()
        "echo "Highlighting hex colors"
    "elseif s:HexColored == 1
        "call s:HexClear()
        "let s:HexColored = s:HexColorize()
        "echo "Refreshing hex colors"
    "endif
"endfunction

function s:HexHighlightToggle()
    if !has("gui_running")
        echo "hexHighlight only works with a graphical version of vim"
        return
    endif
    if s:HexColored == 0
        let s:HexColored = s:HexColorize()
        echo "Highlighting hex colors"
    elseif s:HexColored == 1
        let s:HexColored = s:HexClear()
        echo "Unhighlighting hex colors"
    endif
endfunction

function s:HexClear()
    for hexNum in s:ColorsDict
        exec 'highlight '.hexNum
    endfor
    call clearmatches()
endfunction

function s:PopulateColorsDict()
    let lineNumber = 0
    while lineNumber <= line("$")
        let currentLine = getline(lineNumber)
        let hexLineMatch = 1

        while match(currentLine, '#\x\{6}\|#\x\{3}', 0, hexLineMatch) != -1
            let hexColor = matchstr(currentLine, '#\x\{6}\|#\x\{3}', 0, hexLineMatch)

            if (strlen(hexColor) == 4)
                let hexColor = '#' . substitute(strpart(hexColor, 1), '.', '&&', 'g')
            endif

            let hexNum = strpart(hexColor, 1, 6)

            if !has_key(s:ColorsDict, hexNum)
                let hexComplement = s:CalcVisibleForeground(hexNum)
                let s:ColorsDict[hexNum] = {'hexColor': hexColor, 'hexComplement': hexComplement}
            endif

            let hexLineMatch += 1
        endwhile

        let lineNumber += 1
    endwhile
endfunction

function s:HighlightDict()
    for hexNum in s:ColorsDict
        let hexColor = s:ColorsDict[hexNum][hexColor]
        let hexComplement = s:ColorsDict[hexNum][hexComplement]
        let m = matchadd(hexNum, hexColor)

        if g:HexVisibleText
            exec 'hi ' . hexNum . ' guibg=' . hexColor . ' guifg=' . hexComplement
        else
            exec 'hi ' . hexNum . ' guibg=' . hexColor . ' guifg=' . hexColor
        endif
    endfor
endfunction

" Function: s:CalcVisibleForeground(color) {{{2
" figures out whether a white or black color is contrasting to color
" Args:
"   -color: the color to figure the foreground to
function s:CalcVisibleForeground(color)
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
