scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('yank')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:f = s:scope.funcs('autoload/vital/__latest__/Opmo.vim')
let s:regval = 'foobaa'


function! OpmoYankThemis(motion) abort " {{{
  call s:f.yank(a:motion, operator#user#register())
endfunction " }}}
call operator#user#define('opmo-yank-themis', 'OpmoYankThemis')

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
  let act = "gg0\<Plug>(operator-opmo-yank-themis)iw"
  call s:check(act, 'aaaA', '"')

  let act = "gg0\"b\<Plug>(operator-opmo-yank-themis)iw"
  call s:check(act, 'aaaA', 'b')

  let act = "gg0\<Plug>(operator-opmo-yank-themis)5e"
  call s:check(act, s:lines[0], '"')

  let act = "ggv$\<Plug>(operator-opmo-yank-themis)"
  call s:check(act, s:lines[0], '"')

  let act = "ggvG$\<Plug>(operator-opmo-yank-themis)"
  call s:check(act, join(s:lines, "\n"), '"')
endfunction " }}}

function! s:suite.line() abort " {{{
  let reg = 'c'
  for i in range(1, len(s:lines))
    call setreg(reg, '')
    let act = i . "GV\<Plug>(operator-opmo-yank-themis)"
    call s:check(act, s:lines[i-1] . "\n", '"')
    call s:assert.equals(getreg(reg), '')

    let act = i . "GV\"c\<Plug>(operator-opmo-yank-themis)"
    call s:check(act, s:lines[i-1] . "\n", reg)
  endfor

  let act = "ggVj\<Plug>(operator-opmo-yank-themis)"
  call s:check(act, join(s:lines[: 1], "\n") . "\n", '"')

  let act = "ggVG$\<Plug>(operator-opmo-yank-themis)"
  call s:check(act, join(s:lines, "\n") . "\n", '"')
endfunction " }}}

function! s:suite.block() abort " {{{
  let act = "gg0ll\<C-v>2j\<Plug>(operator-opmo-yank-themis)"
  call s:check(act, "a\nA\nb", '"', 51)

  if &selection == 'exclusive'
    let act = "gg0ll\<C-v>2jl\<Plug>(operator-opmo-yank-themis)"
    call s:check(act, "a\nA\nb", '"', 52)
  endif

  if &selection == 'exclusive'
    let act = "gg0ll\<C-v>2j6l\<Plug>(operator-opmo-yank-themis)"
  else
    let act = "gg0ll\<C-v>2j5l\<Plug>(operator-opmo-yank-themis)"
  endif
  call s:check(act, "aA aaa\nA ccB \nbbA bb", '"', 54)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:

