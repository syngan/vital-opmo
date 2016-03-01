scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" flag: motion: detail (function) {{{
"  n: line : 改行するか. (wrap), eval
"  w: block: 全体をまとめる (wrap)
"  v: block: 垂直方向 (wrap), eval
"  u: block: 下詰め (replace)  eval
"  d: block: あふれたら捨てる (replace)
"  D: block: 足りなかったら削除しない (replace)
"
"  l: line : (eachline)
"  c: char : (eachline)
"  b: block : (eachline)
" }}}

let s:_funcs = {'char' : {'v':'v'}, 'line': {'v':'V'}, 'block': {'v':"\<C-v>"}}


function! s:_knormal(s) abort " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

function! s:_reg_save(motion) abort " {{{
  let reg = '"'
  let regdic = {}
  for r in [reg]
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor
    if a:motion ==# 'block'
    call s:_knormal(printf('gv"%sy', reg))
  endif
  let sel_save = &selection
  let &selection = "inclusive"

  return [reg, regdic, sel_save]
endfunction " }}}

function! s:_reg_restore(regdic, ...) abort " {{{
  for [reg, val] in items(a:regdic[0])
    call setreg(reg, val[0], val[1])
  endfor
  if get(a:000, 0, 0) == 0
    let &selection = a:regdic[1]
  endif
endfunction " }}}

function! s:_block_width(reg) abort " {{{
  return str2nr(getregtype(a:reg)[1:])
endfunction " }}}

" yank(motion) {{{
function! s:yank(motion, ...) abort " {{{
  let regx = get(a:000, 0, '"')
  let txt = s:gettext(a:motion)
  call setreg(regx, txt, a:motion[0])
endfunction " }}}
"}}}

" gettext() {{{
function! s:gettext(motion) abort " {{{
  let [reg; regdic] = s:_reg_save(a:motion)
  try
    let fdic = s:_funcs[a:motion]
    return fdic.gettext(reg)
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.gettext(reg) abort " {{{
  call s:_knormal(printf('`[v`]"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:_funcs.line.gettext(reg) abort " {{{
  call s:_knormal(printf('`[V`]"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:_funcs.block.gettext(reg) abort " {{{
  return getreg(a:reg)
endfunction " }}}
"}}}

" highlight(motion, hlgroup, priority...) {{{
function! s:highlight(motion, hlgroup, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg; regdic] = s:_reg_save(a:motion)
  let priority = get(a:, '1', 10)

  try
    let mids = fdic.highlight(a:hlgroup, priority, getpos("'["), getpos("']"), reg)
    return mids
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.highlight(hlgroup, priority, begin, end, ...) abort " {{{
  if a:begin[1] == a:end[1]
    return [matchadd(a:hlgroup,
    \ printf('\%%%dl\%%>%dc\%%<%dc', a:begin[1], a:begin[2]-1, a:end[2]+1), a:priority)]
  else
    return [
    \ matchadd(a:hlgroup, printf('\%%%dl\%%>%dc', a:begin[1], a:begin[2]-1), a:priority),
    \ matchadd(a:hlgroup, printf('\%%%dl\%%<%dc', a:end[1], a:end[2]+1), a:priority),
    \ matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1], a:end[1]), a:priority)]
  endif
endfunction " }}}

function! s:_funcs.line.highlight(hlgroup, priority, begin, end, ...) abort " {{{
  return [matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1]-1, a:end[1]+1), a:priority)]
endfunction " }}}

function! s:_funcs.block.highlight(hlgroup, priority, begin, end, reg) abort " {{{
  let width = s:_block_width(a:reg)
  echomsg width
  return [matchadd(a:hlgroup,
        \ printf('\%%>%dl\%%<%dl\%%>%dc\%%<%dc',
        \ a:begin[1]-1, a:end[1]+1, a:begin[2]-1, a:begin[2]+width), a:priority)]
endfunction " }}}
"}}}

function! s:unhighlight(mids) abort " {{{
  for m in a:mids
    silent! call matchdelete(m)
  endfor
endfunction " }}}

" replace(motion, str, flags) {{{
function! s:replace(motion, str, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg; regdic] = s:_reg_save(a:motion)

  try
    return fdic.replace(a:str, reg, get(a:000, 0, ''))
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.replace(str, reg, ...) abort " {{{
  call setreg(a:reg, a:str, 'v')
  let end = getpos("']")
  let eline = getline(end[1])
  if len(eline) > end[2]
    let p = 'P'
  else
    let p = 'p'

    if len(eline) < end[2]
      " 手元では起きないけど, travis で死んだ.
      let end[2] = len(eline)
      call setpos("']", end)
    endif
  endif

  call s:_knormal(printf('`[v`]"_d"%s%s', a:reg, p))
endfunction " }}}

function! s:_funcs.line.replace(str, reg, ...) abort " {{{
  call setreg(a:reg, a:str, 'V')
  let begin = getpos("'[")
  let end = getpos("']")
  if end[1] == line('$')
    if begin[1] == 1
      " ファイル全体を消してしまったので,
      " もう一度 yank しなおして, '[, '] を設定しなおす
      let p = 'PG"_ddggVG"' . a:reg . 'y'
    else
      let p = 'p'
    endif
  else
    let p = 'P'
  endif
  call s:_knormal(printf('`[V`]"_d"%s%s', a:reg, p))
endfunction " }}}

" c.f. operation-replace:
" char 最初の行. あとは切り詰め
" line 直前の行にペースト
" block 頭から. あとは切り詰め. あふれたら後ろに
function! s:_funcs.block.replace(str, reg, flags) abort " {{{
  let spos = getpos("'[")
  let epos = getpos("']")
  let width = s:_block_width(a:reg)
  let strs = split(a:str, "\n")
  if epos[1] - spos[1] + 1 <= len(strs)
    if a:flags =~# 'd'
      " あふれは捨てる
      let t = spos[1]
      let b = epos[1]
      if a:flags =~# 'u'
        let strs = strs[len(strs) - (b - t + 1) :]
      endif
    else
      " 下に上書きしていく.
      let t = spos[1]
      let b = spos[1] + len(strs) - 1
      if b > line('$')
        for i in range(b - line('$'))
          call append('$', repeat(' ', spos[2]))
        endfor
      endif
    endif
  elseif a:flags =~# 'D'
    " 不足分は何もしない
    if a:flags =~# 'u'
      " bottom
      let t = epos[1] - len(strs) + 1
      let b = epos[1]
    else " flag =~# 't' or '' (default)
      " top
      let t = spos[1]
      let b = spos[1] + len(strs) - 1
    endif
  else
    " 不足分は空文字に
    let t = spos[1]
    let b = epos[1]
    if a:flags =~# 'u'
      let strs = repeat([''], epos[1] - spos[1] + 1 - len(strs)) + strs
    else
      let strs = strs + repeat([''], epos[1] - spos[1] + 1 - len(strs))
    endif
  endif
  let end = width + spos[2] - 1

  for i in range(b - t + 1)
    call setpos('.', [0, i + t, spos[2], 0])
    call setreg(a:reg, strs[i], 'v')
    if len(getline('.')) < end
      call s:_knormal(printf('v$h"_d"%sp', a:reg))
    else
      call s:_knormal(printf('v%dl"_d"%sP', width - 1, a:reg))
    endif
  endfor
endfunction " }}}
" }}}

" wrap {{{
function! s:wrap(motion, left, right, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg; regdic] = s:_reg_save(a:motion)

  try
    return fdic.wrap(a:left, a:right, reg, get(a:000, 0, ''))
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.wrap(left, right, reg, ...) abort " {{{
  call s:_knormal("`[v`]\<Esc>")
  call setreg(a:reg, a:right, 'v')
  call s:_knormal('`>"' . a:reg . 'p')
  call setreg(a:reg, a:left, 'v')
  call s:_knormal('`<"' . a:reg . 'P')
endfunction " }}}

function! s:_funcs.line.wrap(left, right, reg, flags) abort " {{{
  let v = (a:flags =~# 'n') ? 'V' : 'v'

  call s:_knormal("`[V`]\<Esc>")
  if a:right !=# ''
    call setreg(a:reg, a:right, v)
    call s:_knormal('`>"' . a:reg . 'p')
  endif
  if a:left !=# ''
    call setreg(a:reg, a:left, v)
    call s:_knormal('`<"' . a:reg . 'P')
  endif
" call s:_knormal(printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
"       \ getpos("']")[1], a:right, getpos("'[")[1], a:left))
endfunction " }}}

function! s:_funcs.block.wrap(left, right, reg, flags) abort " {{{
  if a:flags =~# 'v'
    return s:block_wrap_vertical(a:left, a:right, a:reg)
  elseif a:flags =~# 'w'
    " whole 最初と最後.
    return s:_funcs.char.wrap(a:left, a:right, a:reg)
  else
    " 各行
    return s:block_wrap_eachline(a:left, a:right, a:reg)
  endif
endfunction " }}}

function! s:block_wrap_eachline(left, right, reg) abort " {{{
  " 各行について char する.
  " left, right が改行文字をもつと壊れる
  let spos = getpos("'[")
  let epos = getpos("']")
  let end = str2nr(getregtype(a:reg)[1:]) + spos[2] - 1
  call setreg(a:reg, a:right, 'v')
  for line in range(spos[1], epos[1])
    call setpos('.', [0, line, end, 0])
    if len(getline('.')) >= spos[2]
      call s:_knormal('"' . a:reg . 'p')
    endif
  endfor
  call setreg(a:reg, a:left, 'v')
  for line in range(spos[1], epos[1])
    call setpos('.', [0, line, spos[2], 0])
    if len(getline('.')) >= spos[2]
      call s:_knormal('"' . a:reg . 'P')
    endif
  endfor
endfunction " }}}

function! s:block_wrap_vertical(left, right, reg) abort " {{{
  let spos = getpos("'[")
  let blank = repeat(' ', spos[1]-1)

  if a:right !=# ''
    call setreg(a:reg, blank . a:right, 'V')
    call s:_knormal('`>"' . a:reg . 'p')
  endif
  if a:left !=# ''
    call setreg(a:reg, blank . a:left, 'V')
    call s:_knormal('`<"' . a:reg . 'P')
  endif
endfunction " }}}
" }}}

function! s:insert_before(motion, str, ...) abort " {{{
  return call(function('s:wrap'), [a:motion, a:str, ''] + a:000)
endfunction " }}}

function! s:insert_after(motion, str, ...) abort " {{{
  return call(function('s:wrap'), [a:motion, '', a:str] + a:000)
endfunction " }}}

" eachline {{{
function! s:_funcs.char.eachline(func, reg, regdic, spos, epos, ...) abort " {{{
  " last line
  let pos =[a:epos[0], a:epos[1], 1, a:epos[3]]
  call setpos("'[", pos)
  let pos[2] = a:epos[2]
  call setpos("']", pos)
  call a:func('char')
  let pos[2] = 1
  " mid
  for i in range(a:epos[1]-1, a:spos[1]+1, -1)
    let pos[1] = i
    call setpos('.', pos)
    call s:_knormal(printf("V\"%sy", a:reg))
    call s:_reg_restore(a:regdic, 1)
    call a:func('line')
  endfor
  " first line
  call setpos('''[', a:spos)
  let pos =[a:spos[0], a:spos[1], len(getline(a:spos[1])), a:spos[3]]
  call setpos(''']', pos)
  call s:_reg_restore(a:regdic, 1)
  call a:func('char')

  " finalize.
  call setpos("'[", a:spos)
  call setpos("']", a:epos)
endfunction " }}}

function! s:_funcs.line.eachline(func, reg, regdic, spos, epos, ...) abort " {{{
  let pos = copy(a:epos)
  for i in range(a:epos[1], a:spos[1], -1)
    let pos[1] = i
    call setpos('.', pos)
    call s:_knormal(printf('V"%sy', a:reg))
    call s:_reg_restore(a:regdic)
    call a:func('line')
  endfor
  call setpos("'[", a:spos)
  call setpos("']", a:epos)
endfunction " }}}

function! s:_funcs.block.eachline(func, reg, regdic, spos, epos, ...) abort " {{{
  let mark = '`'
  let pos = copy(a:epos)
  let width = s:_block_width(a:reg) - 1
  let pos[2] = a:spos[2]
  for i in range(a:epos[1], a:spos[1], -1)
    let pos[1] = i
    call setpos('.', pos)
    let l = len(getline(i))
    let w = (l < a:spos[2] + width) ? l - a:spos[2]: width
    if w == 0
      call s:_knormal(printf('v"%sy', a:reg))
    else
      call s:_knormal(printf('v%dl"%sy', w, a:reg))
    endif
    call s:_reg_restore(a:regdic, 1) " a:reg の引き戻し.
    call a:func('char')
  endfor

  " reset '[, '], exclusive だと gv すると一つずれる.
  let l = len(getline(a:epos[1]))
  if a:spos[2] + width > a:epos[2]
    call setpos('.', a:spos)
    call s:_knormal(printf("\<C-v>%dj$\"%sy", a:epos[1] - a:spos[1], a:reg))
  else
    if a:regdic[1] == 'exclusive'
      set selection=exclusive
      let a:epos[2] += 1
    endif
    call setpos("'" . mark , a:epos)
    call setpos('.', a:spos)
    call s:_knormal(printf("\<C-v>`%s\"%sy", mark, a:reg))
  endif
endfunction " }}}

function! s:eachline(motion, func, flags) abort " {{{
  if a:flags =~# a:motion[0]
    return a:func(a:motion)
  endif
  let spos = getpos("'[")
  let epos = getpos("']")
  if spos[1] == epos[1]
    return a:func(a:motion)
  endif

  let [reg; regdic] = s:_reg_save(a:motion)
  try
    return s:_funcs[a:motion].eachline(a:func, reg, regdic, spos, epos, a:flags)
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
