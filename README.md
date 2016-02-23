vital-opmo
=====================

[![Build Status](https://travis-ci.org/syngan/vital-opmo.svg?branch=master)](https://travis-ci.org/syngan/vital-opmo)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/cybjgc5u3mb725yc/branch/master?svg=true&label=windows%20build%20master)](https://ci.appveyor.com/project/syngan/vital-opmo)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/cybjgc5u3mb725yc?svg=true&label=windows%20build%20any)](https://ci.appveyor.com/project/syngan/vital-opmo)

# Usage

## Install

```vim
" vim-plug
Plug 'vim-jp/vital.vim'
Plug 'syngan/vital-opmo'
```

- required: [vim-jp/vital.vim](https://github.com/vim-jp/vital.vim)

## Vitalize to your plugin's directory

```vim
:Vitalize --name=your_plugin_name . +Opmo
```

# Examples

## replace

```vim
let s:opmo = vital#of('your_plugin_name').import('Opmo')

function! your_plugin_name#replace(motion) abort " {{{
  let txt = getreg(operator#user#register())
  call s:opmo.replace(a:motion, txt)
endfunction " }}}

call operator#user#define('your_plugin_name-replace', 'your_plugin_name#replace')
```

## evalruby

```vim
function! opmo#evalruby(motion) abort " {{{
  let str = s:opmo.gettext(a:motion)
  let str = substitute(str, '"', '\\"', 'g')
  let str = system('ruby -e "puts lambda{' . str . '}.call"')
  call s:opmo.replace(a:motion, str)
endfunction " }}}
```

## surround

```
:highlight Opmo_HL ctermfg=Blue ctermbg=LightRed
function! opmo#surround(motion) abort " {{{
  let mids = s:opmo.highlight(a:motion, 'Opmo_HL')
  redraw
  let left = input('left: ')
  let right = input('right: ')
  call s:opmo.unhighlight(mids)
  call s:opmo.wrap(a:motion, left, right)
endfunction " }}}
```

# Real World Examples

- [syngan/vim-operator-furround](https://github.com/syngan/vim-operator-furround)
- [syngan/vim-operator-evalf](https://github.com/syngan/vim-operator-evalf)
- [syngan/vim-bluemoon](https://github.com/syngan/vim-bluemoon)

