runtime! plugin/textobj/comment.vim

silent filetype plugin indent on
syntax enable

source t/util/helpers.vim

describe '<Plug>(textobj-comment-a)'

  before
    silent tabedit t/fixtures/paired.c
  end

  after
    bwipeout!
  end

  it 'selects a comment with trailing whitespace'
    26
    Expect SelectAComment() to_have_lnums 26, 27
    call append(5, ["", "\t", ""])
    5
    Expect SelectAComment() to_have_lnums 3, 8
  end

  it 'selects a comment with leading whitespace'
    4
    Expect SelectAComment() to_have_lnums 2, 5
    call append(7, "\t\t")
    9
    Expect SelectAComment() to_have_lnums 8, 9
  end

  it 'selects a comment without whitespace'
    19
    Expect SelectAComment() to_have_lnums 19, 19
    2delete
    Expect SelectAComment() to_have_lnums 2, 4
  end

  it 'selects linewise'
    4
    call SelectAComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-a)v\<Esc>"
    3
    Expect SelectAComment(command) to_have_pos [2, 1], [5, 21]
    8
    Expect SelectAComment(command) to_have_cols 5, 23
  end

end

describe '<Plug>(textobj-comment-i)'

  before
    silent tabedit t/fixtures/paired.c
  end

  after
    bwipeout!
  end

  it 'selects inner comment'
    4
    Expect SelectInnerComment() to_have_lnums 3, 5
    8
    Expect SelectInnerComment() to_have_lnums 8, 8
    26
    Expect SelectInnerComment() to_have_lnums 26, 26
  end

  it 'selects linewise'
    4
    call SelectInnerComment()
    Expect visualmode() ==# 'V'
  end

  it 'sets proper start and end column'
    let command = "v\<Plug>(textobj-comment-i)v\<Esc>"
    3
    Expect SelectInnerComment(command) to_have_pos [3, 1], [5, 21]
    8
    Expect SelectInnerComment(command) to_have_cols 5, 23
    26
    Expect SelectInnerComment(command) to_have_cols 5, 8
  end

end

describe '<Plug>(textobj-comment-inside-i)'

  before
    silent tabedit t/fixtures/paired.c
  end

  after
    bwipeout!
  end

  it 'selects inside comment'
    5
    Expect SelectInsideComment() to_have_pos [3, 4], [5, 18]
    8
    Expect SelectInsideComment() to_have_pos [8, 7], [8, 21]
  end

  it 'selects inside whitespace comment'
    19
    Expect SelectInsideComment() to_have_cols 15, 18
    normal! D
    call append(line("."), ["  \t", "", "\t */"])
    Expect SelectInsideComment() to_have_pos [19, 15], [22, 2]
  end

  it 'selects characterwise'
    8
    call SelectInsideComment()
    Expect visualmode() ==# 'v'
  end

  it 'doesn''t select inside empty comment'
    26
    let @@ = ''
    exe "normal y\<Plug>(textobj-comment-inside-i)"
    Expect @@ == ''
  end

end

describe 'paired leader search'

  before
    silent tabedit t/fixtures/paired.c
  end

  after
    bwipeout!
  end

  it 'proceeds upwards'
    9
    Expect SelectAComment()     to_have_lnums 8, 8
    10
    Expect SelectAComment() not to_have_lnums 8, 8
  end

end
