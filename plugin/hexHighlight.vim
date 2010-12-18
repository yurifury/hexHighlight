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

nnoremap <Plug>RefreshColorScheme :<C-u>call <SID>RefreshColorScheme()<CR>
if ! hasmapto('<Plug>RefreshColorScheme', 'n')
    nmap <Leader>p <Plug>RefreshColorScheme
endif

function! s:RefreshColorScheme()
    exe 'w'
    exe 'colorscheme ' . g:colors_name
endfunction
command! -nargs=? HCT         call s:HighlightCTerms()
command! -nargs=? HHC         call s:HighlightHexCodes()

function! s:HighlightHexCodes()
     
    let lineNumber = 0
    let matchno = 4
    while lineNumber <= line("$")
        let currentLine = getline(lineNumber)

        if match(currentLine, '\v^\s*hi(light)?') != -1
            let hiNameIndex = matchend(currentLine, '\v^\s*hi(light)?')
            if hiNameIndex != -1
                let hiNameMatch = matchstr(currentLine, '\v\w+', hiNameIndex)
            endif

            let guibgIndex = matchend(currentLine, 'guibg=')
            if guibgIndex != -1
                let guibgMatch = matchstr(currentLine, '\v\S+', guibgIndex)
            else
                let guibgMatch = 'NONE'
            endif

            let guifgIndex = matchend(currentLine, 'guifg=')
            if guifgIndex != -1
                let guifgMatch = matchstr(currentLine, '\v\S+', guifgIndex)
            else
                let guifgMatch = 'NONE'
            endif

            let guiIndex = matchend(currentLine, 'gui=')
            if guiIndex != -1
                let guiMatch = matchstr(currentLine, '\v\S+', guiIndex)
            else
                let guiMatch = 'none'
            endif

            "highlight lineNumber guibg= guibgMatch guifg= guifgMatch
            if guifgMatch != 'NONE' || guibgMatch != 'NONE'
                exe 'hi '.matchno.' guibg='.guibgMatch.' guifg='.guifgMatch.' gui='.guiMatch
                "exe 'hi fff'.lineNumber.' guibg='.guibgMatch.' guifg='.guifgMatch
                exe 'let m = matchadd('.matchno.', "'.hiNameMatch.'")'
                "exe "matchadd('fff".lineNumber."', '".hiNameMatch."')"
                "hi hexColor4 guifg=#000000 guibg=#000000
                "let m = matchadd("hexColor4", "#000000", 25, 4)
                let matchno += 1
            endif
        endif
        let lineNumber += 1
    endwhile
    "for cterm in cterms
        "exe 'hi hurp'.cterm.' ctermbg='.cterm.' ctermfg='.cterm
        "exe "let m = matchadd('hurp".cterm."', 'ctermbg=".cterm."')"
        ""echo 'hi hurp'.cterm.' ctermbg='.cterm.' ctermfg='.cterm
        ""echo "let m = matchadd('hurp".cterm."', 'ctermbg=".cterm."')"
    "endfor
endfunction

function! s:HighlightCTerms()
     
    let cterms = range(6,255)

    let lineNumber = 0
    while lineNumber <= line("$")
        let currentLine = getline(lineNumber)

        if match(currentLine, '\v^\s*hi(light)?') != -1
            let hiNameIndex = matchend(currentLine, '\v^\s*hi(light)?')
            let hiNameMatch = matchstr(currentLine, '\v\w+', hiNameIndex)
            echo hiNameMatch
            let ctermbgIndex = matchend(currentLine, 'ctermbg=')
            let ctermbgMatch = matchstr(currentLine, '\v\d+', ctermbgIndex)
            let ctermfgIndex = matchend(currentLine, 'ctermfg=')
            let ctermfgMatch = matchstr(currentLine, '\v\d+', ctermfgIndex)
            if ctermfgMatch == ''
                let ctermfgMatch = none
            endif
            if ctermbgMatch == ''
                let ctermbgMatch = none
            endif
            exe 'hi '.lineNumber.'ctermbg='.ctermbgMatch.' ctermfg='.ctermfgMatch

            exe matchadd(lineNumber, hiNameMatch)
        endif
        let lineNumber += 1
    endwhile
    "for cterm in cterms
        "exe 'hi hurp'.cterm.' ctermbg='.cterm.' ctermfg='.cterm
        "exe "let m = matchadd('hurp".cterm."', 'ctermbg=".cterm."')"
        ""echo 'hi hurp'.cterm.' ctermbg='.cterm.' ctermfg='.cterm
        ""echo "let m = matchadd('hurp".cterm."', 'ctermbg=".cterm."')"
    "endfor
endfunction

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
