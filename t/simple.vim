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

  it 'selects a comment'
    11
    Expect SelectAComment() to_have_lnums 11, 11
    16
    Expect SelectAComment() to_have_lnums 15, 17
    19
    Expect SelectAComment() to_have_lnums 19, 20
  end

  it 'selects linewise'
    5
    call SelectAComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-a)v\<Esc>"
    5
    Expect SelectAComment(command) to_have_cols 1, 18
    17
    Expect SelectAComment(command) to_have_cols 9, 25
    23
    Expect SelectAComment(command) to_have_cols 1, 1
  end

end

describe '<Plug>(textobj-comment-i)'

  before
    silent tabedit t/fixtures/simple.py
  end

  after
    bwipeout!
  end

  it 'selects inner comment'
    11
    Expect SelectInnerComment() to_have_pos [11, 7], [11, 28]
    25
    Expect SelectInnerComment() to_have_pos [25, 2], [25, 9]
    15
    Expect SelectInnerComment() to_have_pos [15, 11], [17, 25]
  end

  it 'selects inner whitespace comment'
    23
    call setline(23, '#   ')
    Expect SelectInnerComment() to_have_pos [23, 2], [23, 4]
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

  it 'selects a big comment with trailing whitespace'
    5
    Expect SelectABigComment() to_have_lnums 5, 6
    11
    Expect SelectABigComment() to_have_lnums 11, 12
  end

  it 'selects a big comment with leading whitespace'
    26d
    normal! k
    Expect SelectABigComment() to_have_lnums 24, 25
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
    Expect SelectAComment()     to_have_lnums 11, 11
    13
    Expect SelectAComment() not to_have_lnums 11, 11
  end

end
