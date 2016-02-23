scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('replace')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:f = s:scope.funcs('autoload/vital/__latest__/Opmo.vim')
let s:regval = 'foobaa'


let s:flags = ''
let s:str = ''
function! OpmoReplaceThemis(motion) abort " {{{
  call s:f.replace(a:motion, s:str, s:flags)
endfunction " }}}
call operator#user#define('opmo-replace', 'OpmoReplaceThemis')

let s:lines = [
      \ 'aaaaaaaaaaaaaaaa',
      \ 'ccccccccccc',
      \ 'bbbbbbbbbbbbbbbbbbbbbbbb',
      \ 'ddddddddddddddddddd',
      \]

function! s:suite.before_each() " {{{
  new
  lockvar s:lines
  call setline(1, s:lines)
  let s:flags = ''
endfunction " }}}

function! s:suite.after_each() " {{{
  quit!
  unlockvar! s:lines
endfunction " }}}

function! s:check(v, str, flag, exp) abort " {{{
  let s:flags = a:flag
  let s:str = a:str
  cal setreg('"', s:regval, 'v')
  execute 'normal' a:v . "\<Plug>(operator-opmo-replace)"
  for i in range(len(a:exp))
    call s:assert.equals(getline(i+1), a:exp[i], i+1)
  endfor
  call s:assert.equals(line('$'), len(a:exp), 'lno')
  call s:assert.equals(getreg('"'), s:regval, 'reg')
endfunction " }}}

function! s:linet(v, str, lines, flags) abort " {{{
  let exp = copy(a:lines)
  let s:flags = a:flags
  for i in range(1, 4)
    let exp[i-1] = a:str
    call s:check(i . 'G0' . a:v, a:str, a:flags, exp)
  endfor
  return exp
endfunction " }}}

function! s:suite.char_line() abort " {{{
  call s:linet('v$', '1234567345678', s:lines, '')
endfunction " }}}

function! s:suite.line_line() abort " {{{
  call s:linet('V', '1234567345678', s:lines, '')
endfunction " }}}

function! s:suite.block_line() abort " {{{
  call s:linet("\<C-v>$", '1234567345678', s:lines, '')
endfunction " }}}

function! s:suite.block_line() abort " {{{
  call s:linet("\<C-v>$", '1234', s:lines, '')
endfunction " }}}

function! s:wholet(v, str, flag, exp) abort " {{{
  call s:check('gg0' . a:v . 'G$', a:str, a:flag, a:exp)
endfunction " }}}

function! s:suite.char_whole() abort " {{{
  let str = '1234567345678'
  call s:wholet('v', str, '', [str])
endfunction " }}}

function! s:suite.line_whole() abort " {{{
  let str = '1234567345678'
  call s:wholet('V', str, '', [str])
endfunction " }}}

function! s:suite.blockt_whole() abort " {{{
  let str = '1234567345678'
  call s:wholet("\<C-v>", str, '', [str, '', '', ''])
endfunction " }}}

function! s:suite.blockt2_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str = join([str1,str2,str3], "\n")
  call s:wholet("\<C-v>", str, '', [str1, str2, str3, ''])
endfunction " }}}

function! s:suite.blocktC_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str = join([str1,str2,str3], "\n")
  call s:wholet("\<C-v>", str, 'C', [str1, str2, str3, s:lines[3]])
endfunction " }}}

function! s:suite.blockb_whole() abort " {{{
  let str = '1234567345678'
  call s:wholet("\<C-v>", str, 'b', ['', '', '', str])
endfunction " }}}

function! s:suite.blockb2_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str = join([str1,str2,str3], "\n")
  call s:wholet("\<C-v>", str, 'b', ['', str1, str2, str3])
endfunction " }}}

function! s:suite.blockbC_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str = join([str1,str2,str3], "\n")
  call s:wholet("\<C-v>", str, 'bC', [s:lines[0], str1, str2, str3])
endfunction " }}}

function! s:suite.blockc_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str4 = 'ddddggg00gggddddddd'
  let str5 = '@@!"#%&''&%$#%&%$'
  let str = join([str1,str2,str3,str4,str5], "\n")
  call s:wholet("\<C-v>", str, 'c', [str1, str2, str3,str4])
endfunction " }}}

function! s:suite.blockcb_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str4 = 'ddddggg00gggddddddd'
  let str5 = '@@!"#%&''&%$#%&%$'
  let str = join([str1,str2,str3,str4,str5], "\n")
  call s:wholet("\<C-v>", str, 'cb', [str2,str3,str4,str5])
endfunction " }}}

function! s:suite.blocko_whole() abort " {{{
  let str1 = '1234567345678'
  let str2 = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str3 = 'min'
  let str4 = 'ddddggg00gggddddddd'
  let str5 = '@@!"#%&''&%$#%&%$'
  let strs = [str1,str2,str3,str4,str5]
  let str = join(strs, "\n")
  call s:wholet("\<C-v>", str, '', strs)
endfunction " }}}

function! s:whole10l(v, str, flag, exp) abort " {{{
  call s:check('gg08l' . a:v . '2j5l', a:str, a:flag, a:exp)
endfunction " }}}

function! s:suite.char_sub() abort " {{{
  let str = '1234567345678'
  call s:whole10l('v', str, '', [s:lines[0][:7] . str . s:lines[2][14:], s:lines[3]])
endfunction " }}}

function! s:suite.line_sub() abort " {{{
  let str = '1234567345678'
  call s:whole10l('V', str, '', [str, s:lines[3]])
endfunction " }}}

function! s:suite.blockt_sub() abort " {{{
  let str = '1234567345678'
  call s:whole10l("\<C-v>", str, '', [
        \ s:lines[0][:7] . str . s:lines[0][14:],
        \ s:lines[1][:7] . s:lines[1][14:],
        \ s:lines[2][:7] . s:lines[2][14:],
        \ s:lines[3]])
endfunction " }}}

function! s:suite.blockt2_sub() abort " {{{
  let strs = [0,0,0,0]
  let strs[0] = '1234567345678'
  let strs[1] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let strs[2] = 'min'
  let str = join(strs[: 2], "\n")
  for i in range(3)
    let strs[i] = s:lines[i][:7] . strs[i] . s:lines[i][14:]
  endfor
  let strs[3] = s:lines[3]
  call s:whole10l("\<C-v>", str, '', strs)
endfunction " }}}

function! s:suite.blocktC_sub() abort " {{{
  let strs = [0,0,0,0]
  let strs[0] = '1234567345678'
  let strs[1] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str = join(strs[: 1], "\n")
  for i in range(2)
    let strs[i] = s:lines[i][:7] . strs[i] . s:lines[i][14:]
  endfor
  let strs[2] = s:lines[2]
  let strs[3] = s:lines[3]
  call s:whole10l("\<C-v>", str, 'C', strs)
endfunction " }}}

function! s:suite.blockb_sub() abort " {{{
  let strs = [0,0,0,0]
  let strs[0] = ''
  let strs[1] = '1234567345678'
  let strs[2] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str = join(strs[1:2], "\n")
  for i in range(3)
    let strs[i] = s:lines[i][:7] . strs[i] . s:lines[i][14:]
  endfor
  let strs[3] = s:lines[3]
  call s:whole10l("\<C-v>", str, 'b', strs)
endfunction " }}}

function! s:suite.blockbC_sub() abort " {{{
  let strs = [0,0,0,0]
  let strs[0] = ''
  let strs[1] = '1234567345678'
  let strs[2] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let str = join(strs[1:2], "\n")
  for i in range(3)
    let strs[i] = s:lines[i][:7] . strs[i] . s:lines[i][14:]
  endfor
  let strs[0] = s:lines[0]
  let strs[3] = s:lines[3]
  call s:whole10l("\<C-v>", str, 'bC', strs)
endfunction " }}}

function! s:suite.blockc_sub() abort " {{{
  let strs = [0,0,0,0,0]
  let strs[0] = '1234567345678'
  let strs[1] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let strs[2] = 'min'
  let strs[3] = 'ddddggg00gggddddddd'
  let strs[4] = '@@!"#%&''&%$#%&%$'
  let str = join(strs, "\n")
  for i in range(3)
    let strs[i] = s:lines[i][:7] . strs[i] . s:lines[i][14:]
  endfor
  let strs[3] = s:lines[3]
  call s:whole10l("\<C-v>", str, 'c', strs[:3])
endfunction " }}}

function! s:suite.blockcb_sub() abort " {{{
  let strs = [0,0,0,0,0]
  let strs[0] = '1234567345678'
  let strs[1] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let strs[2] = 'min'
  let strs[3] = 'ddddggg00gggddddddd'
  let strs[4] = '@@!"#%&''&%$#%&%$'
  let str = join(strs, "\n")
  for i in range(3)
    let strs[i] = s:lines[i][:7] . strs[i+2] . s:lines[i][14:]
  endfor
  let strs[3] = s:lines[3]
  call s:whole10l("\<C-v>", str, 'cb', strs[:3])
endfunction " }}}

function! s:suite.blocko_sub() abort " {{{
  let strs = [0,0,0,0,0]
  let strs[0] = '1234567345678'
  let strs[1] = 'ppppppppppppppppbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  let strs[2] = 'min'
  let strs[3] = 'ddddggg00gggddddddd'
  let strs[4] = '@@!"#%&''&%$#%&%$'
  let str = join(strs, "\n")
  for i in range(4)
    let strs[i] = s:lines[i][:7] . strs[i] . s:lines[i][14:]
  endfor
  let strs[4] = repeat(' ', 8) . strs[4]
  call s:whole10l("\<C-v>", str, '', strs)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
