vital-opmo
=====================

[![Build Status](https://travis-ci.org/syngan/vital-opmo.svg?branch=master)](https://travis-ci.org/syngan/vital-opmo)

# Examples

## replace

```vim
function! opmo#replace(motion) abort " {{{
  let txt = getreg(operator#user#register())
  call s:opmo.replace(a:motion, txt)
endfunction " }}}
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

