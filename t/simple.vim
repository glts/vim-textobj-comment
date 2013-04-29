runtime! plugin/textobj/comment.vim

silent filetype plugin indent on
syntax enable

source t/util/helpers.vim

describe '<Plug>(textobj-comment-a)'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'selects a one-line comment'
    11
    Expect SelectAComment() to_have_lnums 11, 11
  end

  it 'selects a multi-line comment'
    16
    Expect SelectAComment() to_have_lnums 15, 17
  end

  it 'selects linewise'
    5
    call SelectAComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-a)v\<Esc>"
    17
    Expect SelectAComment(command) to_have_cols 9, 25
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
    Expect SelectInnerComment() to_have_pos [11, 7], [11, 28]
  end

  it 'selects inner multi-line comment'
    15
    Expect SelectInnerComment() to_have_pos [15, 11], [17, 25]
  end

  it 'selects inner one-line whitespace comment'
    23
    call setline(23, '#   ')
    Expect SelectInnerComment() to_have_pos [23, 2], [23, 4]
  end

  it 'selects inner multi-line whitespace comment'
    20
    Expect SelectInnerComment() to_have_pos [19, 14], [20, 16]
  end

  it 'selects characterwise'
    5
    call SelectInnerComment()
    Expect visualmode() ==# 'v'
  end

  it 'doesn''t select inside empty comment'
    23
    let @@ = ''
    exe "normal y\<Plug>(textobj-comment-i)"
    Expect @@ == ''
  end

end

describe '<Plug>(textobj-comment-big-a)'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'selects a big one-line comment with trailing whitespace'
    5
    Expect SelectABigComment() to_have_lnums 5, 6
  end

  it 'selects a big one-line comment with leading whitespace'
    12d
    normal! k
    Expect SelectABigComment() to_have_lnums 10, 11
  end

  it 'selects a big multi-line comment'
    16
    Expect SelectABigComment() to_have_lnums 14, 17
  end

  it 'selects linewise'
    5
    call SelectABigComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-big-a)v\<Esc>"
    11
    Expect SelectABigComment(command) to_have_cols 5, 1
    17
    Expect SelectABigComment(command) to_have_cols 1, 25
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
    Expect SelectABigComment()     to_have_lnums 11, 12
    13
    Expect SelectABigComment() not to_have_lnums 11, 12
  end

end
