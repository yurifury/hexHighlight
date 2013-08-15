# vim-hexhighlight

## Description

This plugin provides two functionalities:

1. `<Plug>ToggleHexHighlight` colorizes the background of hexcodes in the format `#aabbcc` or `#abc` in the corresponding color.
2. `<Plug>ToggleSchemeHighlight` applies the formatting defined by all `:highlight` commands to the corresponding line.

Both commands operate on the currently opened file.


## Requirements

This version works with graphical versions of vim **as well as** terminal versions of vim!
In the non-gui case, a 256 color terminal is required and the hexcode is approximated using a couple of scripts from [Vim-toCterm](https://github.com/shawncplus/Vim-toCterm).


## Installation

You can install this plugin using [vim-pathogen](https://github.com/tpope/vim-pathogen/):

```bash
cd ~/.vim/bundle
git clone <URL>
```

Alternatively, you can simply extract everything into your `~/.vim` directory.

If your vim does not correctly detect that it is indeed running from a 256 color terminal, you can force vim to work honor this by setting

```vim
set t_Co=256
```

in your `~/.vimrc`.


## Interface

There is no keybinding exposed by default. I suggest to add keybindings in
your `.vimrc`:

```vim
nmap <F2>           <Plug>ToggleHexHighlight
nmap <leader><F2>   <Plug>ToggleSchemeHighlight
```

