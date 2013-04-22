runtime! plugin/textobj/comment.vim

silent filetype plugin indent on
syntax enable

function! ToHavePositions(actual, expected)
  return a:actual == a:expected
endfunction
function! ToHaveLineNumbers(actual, expected)
  return a:actual[0][0] == a:expected[0] && a:actual[1][0] == a:expected[1]
endfunction
function! ToHaveColumns(actual, expected)
  return a:actual[0][1] == a:expected[0] && a:actual[1][1] == a:expected[1]
endfunction

call vspec#customize_matcher('to_have_pos', {'match': function('ToHavePositions')})
call vspec#customize_matcher('to_have_lnums', {'match': function('ToHaveLineNumbers')})
call vspec#customize_matcher('to_have_cols', {'match': function('ToHaveColumns')})

function! DoSelect(cmd)
  exe "normal" a:cmd
  let [_b, lnum1, col1, _o] = getpos("'<")
  let [_b, lnum2, col2, _o] = getpos("'>")
  return [[lnum1, col1], [lnum2, col2]]
endfunction

function! SelectAComment(...)
  return DoSelect(a:0 ? a:1 : "v\<Plug>(textobj-comment-a)\<Esc>")
endfunction

function! SelectInnerComment(...)
  return DoSelect(a:0 ? a:1 : "v\<Plug>(textobj-comment-i)\<Esc>")
endfunction

function! SelectInsideComment(...)
  return DoSelect(a:0 ? a:1 : "v\<Plug>(textobj-comment-inside-i)\<Esc>")
endfunction

describe '<Plug>(textobj-comment-a)'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'selects a one-line comment with trailing whitespace'
    5
    Expect SelectAComment() to_have_lnums [5, 6]
  end

  it 'selects a one-line comment with leading whitespace'
    12d
    normal! k
    Expect SelectAComment() to_have_lnums [10, 11]
  end

  it 'selects a multi-line comment'
    16
    Expect SelectAComment() to_have_lnums [14, 17]
  end

  it 'selects linewise'
    5
    call SelectAComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-a)v\<Esc>"
    11
    Expect SelectAComment(command) to_have_cols [5, 1]
    17
    Expect SelectAComment(command) to_have_cols [1, 25]
  end

end

describe '<Plug>(textobj-comment-i)'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'selects inner one-line comment'
    11
    Expect SelectInnerComment() to_have_lnums [11, 11]
  end

  it 'selects inner multi-line comment'
    16
    Expect SelectInnerComment() to_have_lnums [15, 17]
  end

  it 'selects linewise'
    5
    call SelectInnerComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-i)v\<Esc>"
    17
    Expect SelectInnerComment(command) to_have_cols [9, 25]
  end

end

describe '<Plug>(textobj-comment-inside-i)'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'selects inside one-line comment'
    11
    Expect SelectInsideComment() to_have_pos [[11, 7], [11, 28]]
  end

  it 'selects inside multi-line comment'
    15
    Expect SelectInsideComment() to_have_pos [[15, 11], [17, 25]]
  end

  it 'selects inside one-line whitespace comment'
    23
    call setline(23, '#   ')
    Expect SelectInsideComment() to_have_pos [[23, 2], [23, 4]]
  end

  it 'selects inside multi-line whitespace comment'
    20
    Expect SelectInsideComment() to_have_pos [[19, 14], [20, 16]]
  end

  it 'selects characterwise'
    5
    call SelectInsideComment()
    Expect visualmode() ==# 'v'
  end

  it 'doesn''t select inside empty comment'
    23
    let @@ = ''
    exe "normal y\<Plug>(textobj-comment-inside-i)"
    Expect @@ == ''
  end

end

describe 'simple leader search'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'proceeds upwards'
    14
    Expect SelectAComment()     to_have_lnums [11, 12]
    13
    Expect SelectAComment() not to_have_lnums [11, 12]
  end

end
