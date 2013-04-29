runtime! plugin/textobj/comment.vim

silent filetype plugin indent on
syntax enable

source t/util/helpers.vim

describe '<Plug>(textobj-comment-a)'

  before
    silent tabedit t/fixtures/Inline.java
  end

  after
    bwipeout!
  end

  it 'selects a comment'
    3
    Expect SelectAComment() to_have_cols 8, 27
    5
    normal! WWW
    Expect SelectAComment() to_have_cols 47, 68
    7
    Expect SelectAComment() to_have_cols 23, 54
    exe "normal! A\<Tab>\<Tab>\<Esc>B"
    Expect SelectAComment() to_have_cols 23, 54
  end

  it 'selects characterwise'
    20
    call SelectAComment()
    Expect visualmode() ==# 'v'
  end

end

describe '<Plug>(textobj-comment-i)'

  before
    silent tabedit t/fixtures/Inline.java
  end

  after
    bwipeout!
  end

  it 'selects inner comment'
    20
    normal! WWW
    Expect SelectInnerComment() to_have_cols 17, 23
    5
    Expect SelectInnerComment() to_have_cols 10, 15
  end

  it 'selects inner whitespace comment'
    20
    normal! WWWW
    Expect SelectInnerComment() to_have_cols 30, 31
    24
    exe "normal c\<Plug>(textobj-comment-i)  \<Tab>\<Esc>"
    Expect SelectInnerComment() to_have_cols 9, 15
  end

  it 'selects characterwise'
    7
    call SelectInnerComment()
    Expect visualmode() ==# 'v'
  end

  it 'doesn''t select inside empty comment'
    22
    call setline(line("."), 'parser = /**/ new JsonParser();')
    let @@ = ''
    exe "normal y\<Plug>(textobj-comment-i)"
    Expect @@ == ''
  end

end

describe '<Plug>(textobj-comment-big-a)'

  before
    silent tabedit t/fixtures/Inline.java
  end

  after
    bwipeout!
  end

  it 'selects a big comment with trailing whitespace'
    3
    normal! ww
    Expect SelectABigComment() to_have_cols 8, 28
    7
    exe "normal! A  \<Tab> \<Esc>b"
    Expect SelectABigComment() to_have_cols 23, 58
    24
    normal! ww
    Expect SelectABigComment() to_have_cols 7, 39
  end

  it 'selects a big comment with leading whitespace'
    5
    normal! WWhr_h
    Expect SelectABigComment() to_have_cols 7, 17
    5
    normal! $
    Expect SelectABigComment() to_have_cols 46, 68
    7
    Expect SelectABigComment() to_have_cols 22, 54
  end

  it 'selects a big comment without whitespace'
    15
    normal! ww
    Expect SelectABigComment() to_have_cols 20, 47
    18
    Expect SelectABigComment() to_have_cols 17, 45
  end

  it 'selects characterwise'
    18
    call SelectABigComment()
    Expect visualmode() ==# 'v'
  end

end

describe 'inline leader search'

  before
    silent tabedit t/fixtures/Inline.java
  end

  after
    bwipeout!
  end

  it 'proceeds towards the right'
    20
    Expect SelectABigComment() to_have_cols 14, 27
    Expect SelectABigComment() to_have_cols 27, 33
    normal! w
    Expect SelectInnerComment() to_have_cols 42, 50
    Expect SelectInnerComment() to_have_cols 47, 73
  end

  it 'doesn''t proceed towards the left'
    15
    Expect SelectAComment()     to_have_lnums 15, 15
    normal! $
    Expect SelectAComment() not to_have_lnums 15, 15
  end

end
