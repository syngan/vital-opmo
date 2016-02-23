scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('wrap')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:f = s:scope.funcs('autoload/vital/__latest__/Opmo.vim')
let s:regval = 'foobaa'


let s:pos = ''
function! OpmoWrapThemis(motion) abort " {{{
  call s:f.wrap(a:motion, '123', '456', s:pos)
endfunction " }}}
call operator#user#define('opmo-wrap', 'OpmoWrapThemis')

let s:lines = [
      \ 'aaaaaaaaaaaaaaaa',
      \ 'bbbbbbbbbbbbbbbbbbbbbbbb',
      \ 'ccccccccccc',
      \ 'ddddddddddddddddddd',
      \]

function! s:suite.before_each() " {{{
  new
  call setline(1, s:lines)
  let s:pos = ''
endfunction " }}}

function! s:suite.after_each() " {{{
  quit!
endfunction " }}}

function! s:linet(n, v) abort " {{{
  cal setreg('"', s:regval, 'v')
  execute 'normal' a:n . 'G0' . a:v . "\<Plug>(operator-opmo-wrap)"
  for i in range(1, 4)
    if i == a:n
      call s:assert.equals(getline(i), '123' . s:lines[i-1] . '456', i)
    else
      call s:assert.equals(getline(i), s:lines[i-1], i)
    endif
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

function! s:wholet(v, pos, each) abort " {{{
  let s:pos = a:pos
  cal setreg('"', s:regval, 'v')
  execute 'normal' 'gg0' . a:v . "G$\<Plug>(operator-opmo-wrap)"
  for i in range(1, 4)
    if a:each
      call s:assert.equals(getline(i), '123' . s:lines[i-1] . '456', i)
    elseif i == 1
      call s:assert.equals(getline(i), '123' . s:lines[i-1], i)
    elseif i == 4
      call s:assert.equals(getline(i), s:lines[i-1] . '456', i)
    else
      call s:assert.equals(getline(i), s:lines[i-1], i)
    endif
  endfor
  call s:assert.equals(line('$'), 4, 'lno')
  call s:assert.equals(getreg('"'), s:regval, 'reg')
endfunction " }}}

function! s:suite.char_whole() abort " {{{
  call s:wholet('v', '', 0)
endfunction " }}}

function! s:suite.line_whole() abort " {{{
  call s:wholet('V', '', 0)
endfunction " }}}

function! s:suite.blockw_whole() abort " {{{
  call s:wholet("\<C-v>", 'w', 0)
endfunction " }}}

function! s:suite.block_whole() abort " {{{
  call s:wholet("\<C-v>", '', 1)
endfunction " }}}

function! s:check(exp) abort " {{{
  for i in range(1, 4)
    call s:assert.equals(getline(i), a:exp[i-1], i)
  endfor
  call s:assert.equals(line('$'), 4, 'lno')
  call s:assert.equals(getreg('"'), s:regval, 'reg')
endfunction " }}}

function! s:suite.char_mid() abort " {{{
  cal setreg('"', s:regval, 'v')
  execute 'normal' "1G0\<Plug>(operator-opmo-wrap)4l"
  let exp = copy(s:lines)
  let exp[0] = substitute(exp[0], '^....\zs', '456', '')
  let exp[0] = substitute(exp[0], '^', '123', '')
  call s:check(exp)

  execute 'normal' "2G3l\<Plug>(operator-opmo-wrap)2l"
  let exp[1] = substitute(exp[1], '^.....\zs', '456', '')
  let exp[1] = substitute(exp[1], '^...\zs', '123', '')
  call s:check(exp)

  execute 'normal' "3G3l\<Plug>(operator-opmo-wrap)$"
  let exp[2] = substitute(exp[2], '$', '456', '')
  let exp[2] = substitute(exp[2], '^...\zs', '123', '')
  call s:check(exp)
" call writefile(getline(1, 4), '/tmp/wrap', 'a')
endfunction " }}}


function! s:suite.blocke_mid() abort " {{{
  let exp = copy(s:lines)
  execute 'normal' "1G0\<C-v>4lj\<Plug>(operator-opmo-wrap)"
  let exp[0] = substitute(exp[0], '^.....\zs', '456', '')
  let exp[0] = substitute(exp[0], '^', '123', '')
  let exp[1] = substitute(exp[1], '^.....\zs', '456', '')
  let exp[1] = substitute(exp[1], '^', '123', '')
  call s:check(exp)

  execute 'normal' "2G05l\<C-v>2l2j\<Plug>(operator-opmo-wrap)"
  for i in [1,2,3]
    let exp[i] = substitute(exp[i], '^........\zs', '456', '')
    let exp[i] = substitute(exp[i], '^.....\zs', '123', '')
  endfor
  call s:check(exp)
endfunction " }}}

function! s:suite.blocke_end() abort " {{{
  let exp = copy(s:lines)
  execute 'normal' "1G13l\<C-v>4l3j\<Plug>(operator-opmo-wrap)"
  for i in [0,1,2,3]
    if len(exp[i]) >= 13
      if len(exp[i]) < 17
        let exp[i] = substitute(exp[i], '$', '456', '')
      else
        let exp[i] = substitute(exp[i], '^.\{17}\zs', '456', '')
      endif
      let exp[i] = substitute(exp[i], '^.\{13}\zs', '123', '')
    endif
  endfor
  call s:check(exp)
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
