scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('gettext')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:f = s:scope.funcs('autoload/vital/__latest__/Opmo.vim')
let s:regval = 'foobaa'


function! OpmoYankThemis(motion) abort " {{{
  let txt = s:f.gettext(a:motion)
  call setreg(operator#user#register(), txt)
endfunction " }}}
call operator#user#define('opmo-gettext-themis', 'OpmoYankThemis')

let s:lines = [
      \ 'aaaA aaaB aaaC aaaD aaaE',
      \ 'ccA ccB ccC ccD ccE',
      \ 'bbbbA bbbbB bbbbC bbbbD bbbbE',
      \ 'dddA dddB dddC dddD dddE',
      \]

function! s:suite.before_each() " {{{
  new
  lockvar s:lines
  let s:exp = copy(s:lines)
  call setline(1, s:lines)
  let s:flags = ''
endfunction " }}}

function! s:suite.after_each() " {{{
  quit!
  unlockvar! s:lines
endfunction " }}}

function! s:check(do, txt, reg, ...) abort " {{{
  cal setreg('"', s:regval, 'v')
  execute 'normal' a:do
  for i in range(len(s:exp))
    call s:assert.equals(getline(i+1), s:exp[i], i+1)
  endfor
  call s:assert.equals(line('$'), len(s:exp), 'lno')
  call s:assert.equals(getreg(a:reg), a:txt, 'reg=' . a:reg . ',id=' . get(a:000, 0, ''))
endfunction " }}}

function! s:suite.char() abort " {{{
  let act = "gg0\<Plug>(operator-opmo-gettext-themis)iw"
  call s:check(act, 'aaaA', '"', 1)

  let act = "gg0\"b\<Plug>(operator-opmo-gettext-themis)iw"
  call s:check(act, 'aaaA', 'b', 2)

  let act = "gg0ve\<Plug>(operator-opmo-gettext-themis)"
  call s:check(act, 'aaaA', '"', 3)

  if &selection == 'exclusive'
    let act = "gg0v4l\<Plug>(operator-opmo-gettext-themis)"
  else
    let act = "gg0v3l\<Plug>(operator-opmo-gettext-themis)"
  endif
  call s:check(act, 'aaaA', '"', 5)

  let act = "gg0\<Plug>(operator-opmo-gettext-themis)5e"
  call s:check(act, s:lines[0], '"', 6)

  let act = "ggv$\<Plug>(operator-opmo-gettext-themis)"
  call s:check(act, s:lines[0], '"', 7)

  let act = "ggvG$\<Plug>(operator-opmo-gettext-themis)"
  call s:check(act, join(s:lines, "\n"), '"', 9)
endfunction " }}}

function! s:suite.line() abort " {{{
  let reg = 'c'
  for i in range(1, len(s:lines))
    call setreg(reg, '')
    let act = i . "GV\<Plug>(operator-opmo-gettext-themis)"
    call s:check(act, s:lines[i-1] . "\n", '"', 22 . i . '-2')
    call s:assert.equals(getreg(reg), '')

    let act = i . "GV\"c\<Plug>(operator-opmo-gettext-themis)"
    call s:check(act, s:lines[i-1] . "\n", reg, 22 . i . '-3')
  endfor

  let act = "ggVj\<Plug>(operator-opmo-gettext-themis)"
  call s:check(act, join(s:lines[: 1], "\n") . "\n", '"', 23)

  let act = "ggVG$\<Plug>(operator-opmo-gettext-themis)"
  call s:check(act, join(s:lines, "\n") . "\n", '"', 24)
endfunction " }}}

function! s:suite.block() abort " {{{
  let act = "gg0ll\<C-v>2j\<Plug>(operator-opmo-gettext-themis)"
  call s:check(act, "a\nA\nb", '"', 51)

  if &selection == 'exclusive'
    let act = "gg0ll\<C-v>2jl\<Plug>(operator-opmo-gettext-themis)"
    call s:check(act, "a\nA\nb", '"', 52)
  endif

  if &selection == 'exclusive'
    let act = "gg0ll\<C-v>2j6l\<Plug>(operator-opmo-gettext-themis)"
  else
    let act = "gg0ll\<C-v>2j5l\<Plug>(operator-opmo-gettext-themis)"
  endif
  call s:check(act, "aA aaa\nA ccB \nbbA bb", '"', 54)
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:

