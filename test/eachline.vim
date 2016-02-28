scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('eachline')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:f = s:scope.funcs('autoload/vital/__latest__/Opmo.vim')
let s:regval = 'foobaa'


let s:flags = ''
let s:str = ''
function! OpmoEachLineThemisCL(motion) abort " {{{
  call s:f.replace(a:motion, s:str)
endfunction " }}}
function! OpmoEachLineThemis(motion) abort " {{{
  call s:f.eachline(a:motion, function('OpmoEachLineThemisCL'), '')
  call s:f.wrap(a:motion, '(', ')', 'w')
endfunction " }}}
call operator#user#define('opmo-eachline-themis', 'OpmoEachLineThemis')

let s:lines = [
      \ 'aaaA aaaB aaaC aaaD aaaE',
      \ 'ccA ccB ccC ccD ccE',
      \ 'bbbbA bbbbB bbbbC bbbbD bbbbE',
      \ 'dddA dddB dddC dddD dddE',
      \]

function! s:suite.before_each() " {{{
  new
  lockvar s:lines
  call setline(1, s:lines)
  let s:flags = ''
  let s:str = '1234'
endfunction " }}}

function! s:suite.after_each() " {{{
  quit!
  unlockvar! s:lines
endfunction " }}}

function! s:check(do, str, flag, exp) abort " {{{
  let s:flags = a:flag
  let s:str = a:str
  cal setreg('"', s:regval, 'v')
  execute 'normal' a:do
  for i in range(len(a:exp))
    call s:assert.equals(getline(i+1), a:exp[i], i+1)
  endfor
  call s:assert.equals(line('$'), len(a:exp), 'lno')
  call s:assert.equals(getreg('"'), s:regval, 'reg')
endfunction " }}}

function! s:suite.char_mline() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[1] = substitute(exp[1], 'ccB.*$', '(' . str, '')
  let exp[2] = str
  let exp[3] = substitute(exp[3], '^dddA', str . ')', '')
  call setpos('.', [0, 2, 5, 0])
  let act = "\<Plug>(operator-opmo-eachline-themis)10e"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.char_line() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[1] = '(' . str . ')'
  let act = "2Gv$\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.char_word() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  call search('ccB')
  let exp[1] = substitute(exp[1], 'ccB', '(' . str . ')', '')
  let act = "\<Plug>(operator-opmo-eachline-themis)iw"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.line_mline() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[1] = '(' . str
  let exp[2] = str . ')'
  let act = "2GVj$\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.line_1line() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[1] = '(' . str . ')'
  let act = "2GV$\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.block_1line() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  call search('ccB')
  let exp[1] = substitute(exp[1], 'ccB', '(' . str . ')', '')
  let act = "\<Plug>(operator-opmo-eachline-themis)iw"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.block_mline() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  call search('aaaB')
  let exp[0] = substitute(exp[0], 'aaaB', '(' . str, '')
  let exp[1] = substitute(exp[1], 'cB..', str, '')
  let exp[2] = substitute(exp[2], 'A\zs bbb', str . ')', '')
  let act = "\<C-v>2j3l\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.block_over() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  call search('aD')
  let exp[0] = substitute(exp[0], 'aD a', '(' . str, '')
  let exp[1] = substitute(exp[1], 'cE', str, '')
  let exp[2] = substitute(exp[2], ' bbb\zebD', str . ')', '')
  let act = "\<C-v>2j3l\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.block_dol() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  call search('aaaB')
  let exp[0] = substitute(exp[0], 'aaaB.*', '(' . str, '')
  let exp[1] = substitute(exp[1], 'cB...*', str, '')
  let exp[2] = substitute(exp[2], 'A\zs bbb.*', str . ')', '')
  let act = "\<C-v>2j$\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.char_whole() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[0] = '(' . str
  let exp[1] = str
  let exp[2] = str
  let exp[3] = str . ')'
  let act = "gg0vG$\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.line_whole() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[0] = '(' . str
  let exp[1] = str
  let exp[2] = str
  let exp[3] = str . ')'
  let act = "ggVG\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

function! s:suite.block_whole() abort " {{{
  let exp = copy(s:lines)
  let str = '1234'
  let exp[0] = '(' . str
  let exp[1] = str
  let exp[2] = str
  let exp[3] = str . ')'
  let act = "gg0\<C-v>G$\<Plug>(operator-opmo-eachline-themis)"
  cal s:check(act, str, '', exp)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
