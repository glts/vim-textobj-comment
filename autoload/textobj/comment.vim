" textobj-comment - Text objects for comments
" Author: glts <676c7473@gmail.com>
" Date: 2013-05-03
" Version: 1.0.0

" Select() {{{1

" The Select() function contains the main algorithm for finding comments.
" First we look for a full-line comment with simple leader or with paired
" leader under the cursor, then for inline and end-of-line comments at the
" cursor position, and finally for the nearest full-line comment above.
function! s:Select(inside, whitespace) abort
  let [simple_leaders, paired_leaders] = s:GetLeaders()
  if empty(simple_leaders + paired_leaders)
    return 0
  endif

  let pos = getpos(".")[1:2]

  " Search for simple leader first to avoid being caught up in strange paired
  " leaders
  let comment = s:FindSimpleLineComment(pos, simple_leaders, 0)
  if !empty(comment)
    return s:AdjustLineEnds(comment, a:whitespace, a:inside)
  endif
  let comment = s:FindPairedLineComment(pos, paired_leaders, 0)
  if !empty(comment)
    return s:AdjustLineEnds(comment, a:whitespace, a:inside)
  endif

  let comment = s:FindInlineComment(pos, simple_leaders, paired_leaders)
  if !empty(comment)
    return s:AdjustInlineEnds(comment, a:whitespace, a:inside)
  endif

  let scomment = s:FindSimpleLineComment(pos, simple_leaders, 1)
  let pcomment = s:FindPairedLineComment(pos, paired_leaders, 1)
  if !empty(scomment) || !empty(pcomment)
    if empty(scomment)
      let comment = pcomment
    elseif empty(pcomment)
      let comment = scomment
    else
      let comment = pcomment[2][0] > scomment[2][0] ? pcomment : scomment
    endif
    return s:AdjustLineEnds(comment, a:whitespace, a:inside)
  endif

  return 0
endfunction

" Comment leaders {{{1

" Comment delimiters are called "leaders" in the help. We extract them from
" the current 'comments' setting into two types, simple and paired comment
" leaders. The 'commentstring' setting is used as fallback and verification.

function! s:GetLeaders() abort
  let leaders = map(split(&comments, '\\\@<!,'), 's:partition(v:val, ":")')
  if empty(leaders) && &commentstring =~# '.%s'
    let cmsleader = s:partition(&commentstring, "%s")
    if cmsleader[1] == ''
      let leaders = [['', substitute(cmsleader[0],'\s*$','','')]]
    else
      let leaders = [['s',substitute(cmsleader[0],'\s*$','','')], ['e',substitute(cmsleader[1],'^\s*','','')]]
    endif
  endif
  return [s:GetSimpleLeaders(leaders), s:GetPairedLeaders(leaders)]
endfunction

function! s:GetSimpleLeaders(leaders) abort
  return map(filter(copy(a:leaders), 'v:val[0]=~#"^[bnO]*$"'), 'v:val[1]')
endfunction

function! s:GetPairedLeaders(leaders) abort
  let seleaders = filter(copy(a:leaders), 'v:val[0]=~#"[se]"')
  let pairedleaders = []
  " Only use valid pairs, favour those verifiable through 'commentstring'
  while len(seleaders) >= 2
    let [s, e; seleaders] = seleaders
    if s[0] !~# "s" || e[0] !~# "e"
      call insert(seleaders, e)
      continue
    elseif &commentstring =~# '\V\^\s\*'.s:escape(s[1]).'\s\*%s\s\*'.s:escape(e[1]).'\s\*\$'
      call insert(pairedleaders, [s[1], e[1]])
    else
      call add(pairedleaders, [s[1], e[1]])
    endif
  endwhile
  return pairedleaders  " e.g. [['/*','*/'], ['* -','*/']]
endfunction

" Comment search {{{1

" The comment search functions all return a list [leader, start, end], where
" leader is the comment character or pair of characters, and start and end are
" the byte positions of the opening and closing leaders (for simple leaders
" the end is on the last byte position in the line). Empty when no match.

" s:FindSimpleLineComment() {{{2
function! s:FindSimpleLineComment(pos, simple_leaders, upwards) abort
  let cursor_line = a:pos[0]

  if a:upwards && !empty(a:simple_leaders)
    let allre = '\V\^\s\*\%(' . join(map(copy(a:simple_leaders),'s:escape(v:val)'),'\|') . '\)'
    while cursor_line > 1
      let cursor_line -= 1
      if getline(cursor_line) =~# allre
        break
      endif
    endwhile
  endif

  for simple in a:simple_leaders
    let simplere = '\V\^\s\*' . s:escape(simple)
    if getline(cursor_line) =~# simplere
      let startline = cursor_line
      let ln = cursor_line - 1
      while ln > 0
        if getline(ln) !~# simplere
          break
        endif
        let startline = ln
        let ln -= 1
      endwhile
      let endline = cursor_line
      let ln = cursor_line + 1
      while ln <= line("$")
        if getline(ln) !~# simplere
          break
        endif
        let endline = ln
        let ln += 1
      endwhile
      let startcol = match(getline(startline) ,'\V\^\s\*\zs'.s:escape(simple)) + 1
      let endcol = match(getline(endline), '.$') + 1
      return [simple, [startline, startcol], [endline, endcol]]
    endif
  endfor

  return []
endfunction

" s:FindPairedLineComment() {{{2
function! s:FindPairedLineComment(pos, paired_leaders, upwards) abort
  let found = []
  for pair in a:paired_leaders
    let pairpos = s:FindNearestPair(a:pos, pair, a:upwards)
    if pairpos != []
      if !a:upwards
        let found = [pair, pairpos[0], pairpos[1]]
        break
      else
        if found == [] || s:compare(found[2], pairpos[1]) < 0
          let found = [pair, pairpos[0], pairpos[1]]
        endif
      endif
    endif
  endfor
  return found
endfunction

" s:FindNearestPair() {{{2
function! s:FindNearestPair(pos, pair, upwards) abort
  let [open, close] = a:pair
  let start = []
  let end   = []

  " We will often use variations of the regexp idiom "open((close)\@!.)*close"
  let endre = '\V\^\%(\%('.s:escape(close).'\)\@!\.\)\*\zs'.s:escape(close).'\s\*\$'
  let startre = '\V\^\s\*\zs'.s:escape(open)
  let ere = '\V'.s:escape(close)

  " Search for a full-line comment either on the cursor line or above it
  if !a:upwards
    let ln = a:pos[0]
    while ln <= line("$")
      if getline(ln) =~# ere
        let col = match(getline(ln), endre)
        if col >= 0
          let end = [ln, col + 1]
        endif
        break
      endif
      let ln += 1
    endwhile
    if end != []
      let ln = end[0]
      " Start line can be the same as end line (one-line comment) or above
      let col = match(getline(ln), startre)
      if col >= 0 && ln == a:pos[0]
        let start = [ln, col + 1]
      else
        let ln -= 1
        while ln > 0
          if getline(ln) =~# ere
            break
          endif
          let col = match(getline(ln), startre)
          if col >= 0 && ln <= a:pos[0]
            let start = [ln, col + 1]
            " Don't break, find better start candidates still
          endif
          let ln -= 1
        endwhile
      endif
    endif
  else
    let ln = a:pos[0] - 1
    while ln > 0 && empty(start)
      let col = match(getline(ln), endre)
      if col >= 0
        let end = [ln, col + 1]
        " Found possible end, look upwards for a matching start
        let col = match(getline(ln), startre)
        if col >= 0
          let start = [ln, col + 1]
        else
          let nextln = ln - 1
          while nextln > 0
            if getline(nextln) =~# ere
              break
            endif
            let col = match(getline(nextln), startre)
            if col >= 0
              let start = [nextln, col + 1]
              " Don't break, find better start candidates still
            endif
            let nextln -= 1
          endwhile
        endif
      endif
      let ln -= 1
    endwhile
  endif

  " Expand multiple one-line comments to one big comment
  if start != [] && end != [] && start[0] == end[0]
    let startre = '\V\^\s\*\zs'.s:escape(open).'\%(\%('.s:escape(close).'\)\@!\.\)\*'.s:escape(close).'\s\*\$'
    let endre = '\V\^\s\*'.s:escape(open).'\%(\%('.s:escape(close).'\)\@!\.\)\*\zs'.s:escape(close).'\s\*\$'

    let ln = start[0] - 1
    while ln > 0
      let col = match(getline(ln), startre)
      if col < 0
        break
      endif
      let [start[0], start[1]] = [ln, col+1]
      let ln -= 1
    endwhile

    let ln = end[0] + 1
    while ln <= line("$")
      let col = match(getline(ln), endre)
      if col < 0
        break
      endif
      let [end[0], end[1]] = [ln, col+1]
      let ln += 1
    endwhile
  endif

  return start == [] || end == [] ? [] : [start, end]
endfunction

" s:FindInlineComment() {{{2
function! s:FindInlineComment(pos, simple_leaders, paired_leaders) abort
  " Since we are working with searchpos() to search for inline comments, it is
  " important to always restore the cursor position
  let save_pos = getpos(".")

  " Find the first simple comment in the line. If it is to the left of the
  " cursor return it, else remember it for later. We must do this first to
  " avoid getting caught up in strange paired leaders, such as in Vim script.
  let simple = []
  if !empty(a:simple_leaders)
    call cursor(a:pos[0], 1)
    let simplere = '\V' . join(map(copy(a:simple_leaders),'"\\(".s:escape(v:val)."\\)"'),'\|')
    let [lnum, col, submatch] = searchpos(simplere, 'npW', line("."))
    if lnum != 0 && col != 0
      let endcol = match(getline(lnum), '.$') + 1
      let simple = [a:simple_leaders[submatch-2], [lnum, col], [lnum, endcol]]
      if col <= a:pos[1]
        call setpos(".", save_pos)
        return simple
      endif
    endif
    call setpos(".", save_pos)
  endif

  " Find a paired comment surrounding the cursor position
  for [open, close] in a:paired_leaders
    let sre = '\V'.s:escape(open)
    let ere = '\V'.s:escape(close)

    let start = []
    call cursor(a:pos[0], a:pos[1])
    let end = searchpos(ere, 'cen', line("."))
    if end != [0, 0]
      " We have found an end but must avoid matching <!---> or similar
      let end[1] -= strlen(close) - 1
      call cursor(0, end[1])
      let nextend = searchpos(ere, 'ben', line("."))
      let nextstart = searchpos(sre, 'be', line("."))
      while nextstart != [0, 0] && (nextend == [0, 0] || s:compare(nextstart, nextend) > 0)
        let start = nextstart
        let nextstart = searchpos(sre, 'be', line("."))
      endwhile
      if start != []
        let start[1] -= strlen(open) - 1
        if a:pos[1] >= start[1]
          call setpos(".", save_pos)
          return [[open, close], start, end]
        endif
      endif
    endif
    call setpos(".", save_pos)
  endfor

  " Find the next paired or simple comment towards the right
  for [open, close] in a:paired_leaders
    let sre = '\V'.s:escape(open)
    let ere = '\V'.s:escape(close)

    " Start searching for comment start after cursor position
    call cursor(a:pos[0], a:pos[1])
    let start = searchpos(sre, 'n', line("."))
    let end = searchpos(ere, 'n', line("."))
    if start != [0, 0] && end != [0, 0] && s:compare(start, end) < 0
      " Search again for the proper end, we must avoid matching <!--->
      call cursor(0, start[1] + strlen(open)-1)
      let end = searchpos(ere, 'n', line("."))
      if end != [0, 0]
        if empty(simple) || !empty(simple) && s:compare(start, simple[1]) < 0
          call setpos(".", save_pos)
          return [[open, close], start, end]
        endif
      endif
    endif
    call setpos(".", save_pos)
  endfor

  call setpos(".", save_pos)
  return simple
endfunction

" Selection adjustment {{{1

" These functions adjust the ends of the selection and return the list
" required by textobj-user, or 0 on failure. Adjustment is generally
" multibyte-safe. Multibyte space characters are not handled properly.

" s:AdjustLineEnds() {{{2
function! s:AdjustLineEnds(comment, whitespace, inside) abort
  if a:inside
    return s:AdjustInsideEnds(a:comment)
  endif

  let [leader, start, end] = a:comment

  " For paired leaders, move the end over the end leader
  if type(leader) == type([])
    let end[1] += strlen(leader[1]) - 1
  endif

  " For "aC", move the end over trailing blank lines, if there aren't any move
  " the start over leading blank lines
  if a:whitespace
    if end[0] + 1 <= line("$") && s:isblank(end[0] + 1)
      let ln = end[0] + 1
      while ln <= line("$") && s:isblank(ln)
        let [end[0], end[1]] = [ln, 1]
        let ln += 1
      endwhile
    else
      let ln = start[0] - 1
      while ln > 0 && s:isblank(ln)
        let [start[0], start[1]] = [ln, 1]
        let ln -= 1
      endwhile
    endif
  endif

  return [ "V", [0, start[0], start[1], 0], [0, end[0], end[1], 0] ]
endfunction

" s:AdjustInlineEnds() {{{2
function! s:AdjustInlineEnds(comment, whitespace, inside) abort
  if a:inside
    return s:AdjustInsideEnds(a:comment)
  endif

  let [leader, start, end] = a:comment

  if type(leader) == type([])
    " For "ac" and "aC", move the end over the end leader
    let end[1] += strlen(leader[1]) - 1
    " For "aC", move the end over trailing whitespace, if there isn't any move
    " the start over leading whitespace
    if a:whitespace
      call cursor(end[0], end[1])
      let newend = searchpos('\S', 'n', line("."))
      let lastcol = match(getline(line(".")), '.$') + 1
      if newend == [0, 0] && end[1] != lastcol
        let end[1] = lastcol
      elseif end[1] < newend[1] - 1
        let end[1] = newend[1] - 1
      else
        call cursor(0, start[1])
        let newstart = searchpos('\S', 'bn', line("."))
        if newstart != [0, 0]
          let start[1] = s:nextcol(0, newstart[1])
        endif
      endif
    endif
  else
    if a:whitespace
      " For "aC", move the end over trailing whitespace, if there isn't any
      " move the start over leading whitespace
      call cursor(end[0], end[1])
      let newend = searchpos('\s$', 'cn', line("."))
      if newend == [0, 0]
        call cursor(0, start[1])
        let newstart = searchpos('\S', 'bn', line("."))
        let start[1] = s:nextcol(0, newstart[1])
      endif
    else
      " For "ac", move the end to the last non-whitespace character
      let end[1] = start[1] + strlen(leader) - 1
      call cursor(end[0], end[1])
      let newend = searchpos('\S\s*$', 'n', line("."))
      if newend != [0, 0]
        let [end[0], end[1]] = [newend[0], newend[1]]
      endif
    endif
  endif

  return [ "v", [0, start[0], start[1], 0], [0, end[0], end[1], 0] ]
endfunction

" s:AdjustInsideEnds() {{{2
function! s:AdjustInsideEnds(comment) abort
  let [leader, start, end] = a:comment

  if type(leader) == type([])
    " Move the start over the start leader
    let start[1] += strlen(leader[0]) - 1
    " Either select non-whitespace content, but if there is none select
    " whitespace or nothing
    call cursor(start[0], start[1])
    let newstart = searchpos('\V'.s:escape(leader[1]).'\|\S', 'nW')
    if s:compare(newstart, end) < 0
      let [start[0], start[1]] = [newstart[0], newstart[1]]
      call cursor(end[0], end[1])
      let [end[0], end[1]] = searchpos('\S', 'bnW')
    else
      if s:compare([start[0], start[1] + 1], end) < 0
        let start[1] += 1
        call cursor(end[0], end[1])
        " Special treatment for cursor at start of line
        let [end[0], end[1]] = searchpos(end[1]==1 ? '$' : '.', 'bnW')
      else
        return 0
      endif
    endif
  else
    let start[1] += strlen(leader) - 1
    call cursor(start[0], start[1])
    if start[0] == end[0]
      " For one-line comments with simple leader select non-whitespace
      " content, but if there is none select whitespace or nothing
      let newstart = searchpos('\S', 'n', line("."))
      let newend = searchpos('\S\s*$', 'n', line("."))
      if newstart != [0, 0] && newend != [0, 0]
        let [start[0], start[1]] = [newstart[0], newstart[1]]
        let [end[0], end[1]] = [newend[0], newend[1]]
      else
        let newstart = searchpos('\s', 'n', line("."))
        let newend = searchpos('\s$', 'n', line("."))
        if newstart != [0, 0] && newend != [0, 0]
          let [start[0], start[1]] = [newstart[0], newstart[1]]
          let [end[0], end[1]] = [newend[0], newend[1]]
        else
          return 0
        endif
      endif
    else
      " It isn't clear what the appropriate behaviour for multi-line comments
      " with simple leader should be, we try to move the start to the first \S
      let newstart = searchpos('\S', 'n', line("."))
      let start[1] = newstart[1] ? newstart[1] : start[1] + 1
    endif
  endif

  return [ "v", [0, start[0], start[1], 0], [0, end[0], end[1], 0] ]
endfunction

" Utilities {{{1

function! s:partition(str, delim) abort
  let idx = stridx(a:str, a:delim)
  return idx < 0 ? [a:str, ''] : [strpart(a:str,0,idx), strpart(a:str,idx+strlen(a:delim))]
endfunction

function! s:nextcol(lnum, col) abort
  let col = match(strpart(getline(a:lnum > 0 ? a:lnum : line(".")), a:col-1), '.\zs.')
  return col < 0 ? -1 : col + a:col
endfunction

function! s:escape(str) abort
  return escape(a:str, '\')
endfunction

function! s:isblank(lnum) abort
  return getline(a:lnum) =~ '^\s*$'
endfunction

function! s:compare(pos1, pos2) abort
  if a:pos1[0] < a:pos2[0]
    return -1
  elseif a:pos1[0] > a:pos2[0]
    return 1
  elseif a:pos1[1] < a:pos2[1]
    return -1
  elseif a:pos1[1] > a:pos2[1]
    return 1
  endif
  return 0
endfunction

" Public interface {{{1

function! textobj#comment#select_a() abort
  return s:Select(0, 0)
endfunction

function! textobj#comment#select_i() abort
  return s:Select(1, 0)
endfunction

function! textobj#comment#select_big_a() abort
  return s:Select(0, 1)
endfunction
