scriptencoding utf-8

" insufficient test
let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('highlight')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:f = s:scope.funcs('autoload/vital/__latest__/Opmo.vim')
let s:regval = 'foobaa'

function! OpmoHlThemis(motion) abort " {{{
  let s:mids = s:f.highlight(a:motion, 'Opmo_red')
endfunction " }}}
call operator#user#define('opmo-highlight-themis', 'OpmoHlThemis')

function! s:suite.before() " {{{
  highlight Opmo_red    gui=bold ctermfg=red   ctermbg=gray
endfunction " }}}

function! s:suite.after() abort " {{{
  highlight clear Opmo_red
endfunction " }}}

let s:lines = [
      \ 'abcdefghijklmnop',
      \ 'ABCDEFGHIJKLMNOPQRSTUVWX',
      \ '01234567890',
      \ 'aAbBcCdDeEfFgGhHiIj',
      \]

function! s:suite.before_each() " {{{
  new
  call setline(1, s:lines)
  let s:mids = []
endfunction " }}}

function! s:suite.after_each() " {{{
  for m in s:mids
    silent! call matchdelete(m)
  endfor
  quit!
endfunction " }}}

function! s:test(...) abort " {{{
endfunction " }}}

function! s:linet(n, v) abort " {{{
  cal setreg('"', s:regval, 'v')
  execute 'normal' a:n . 'G0' . a:v . "\<Plug>(operator-opmo-highlight-themis)"
  for i in range(1, 4)
    call s:assert.equals(getline(i), s:lines[i-1], i)
  endfor
  call s:assert.equals(line('$'), 4, 'lno')
  call s:assert.equals(getreg('"'), s:regval, 'reg')
endfunction " }}}

function! s:suite.char_line1() abort " {{{
  call s:linet(1, 'v$')
endfunction " }}}

function! s:suite.char_line2() abort " {{{
  call s:linet(2, 'v$')
endfunction " }}}

function! s:suite.char_line3() abort " {{{
  call s:linet(3, 'v$')
endfunction " }}}

function! s:suite.char_line4() abort " {{{
  call s:linet(4, 'v$')
endfunction " }}}

function! s:suite.line_line1() abort " {{{
  call s:linet(1, 'V')
endfunction " }}}

function! s:suite.line_line2() abort " {{{
  call s:linet(2, 'V')
endfunction " }}}

function! s:suite.line_line3() abort " {{{
  call s:linet(3, 'V')
endfunction " }}}

function! s:suite.line_line4() abort " {{{
  call s:linet(4, 'V')
endfunction " }}}

function! s:suite.block_line1() abort " {{{
  call s:linet(1, "\<C-v>$")
endfunction " }}}

function! s:suite.block_line2() abort " {{{
  call s:linet(2, "\<C-v>$")
endfunction " }}}

function! s:suite.block_line3() abort " {{{
  call s:linet(3, "\<C-v>$")
endfunction " }}}

function! s:suite.block_line4() abort " {{{
  call s:linet(4, "\<C-v>$")
endfunction " }}}

function! s:wholet(v, ...) abort " {{{
  cal setreg('"', s:regval, 'v')
  execute 'normal' 'gg0' . a:v . "G$\<Plug>(operator-opmo-highlight-themis)"
  let d = {}
  for i in range(1, 4)
    call s:assert.equals(getline(i), s:lines[i-1], i)
    let d[getline(i)] = 'Opmo_red'
  endfor
  call s:assert.equals(line('$'), 4, 'lno')
  call s:assert.equals(getreg('"'), s:regval, 'reg')
  call s:test(d, 'whole')
endfunction " }}}

function! s:suite.char_whole() abort " {{{
  call s:wholet('v', '')
endfunction " }}}

function! s:suite.line_whole() abort " {{{
  call s:wholet('V', '')
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
