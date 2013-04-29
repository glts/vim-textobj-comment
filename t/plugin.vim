runtime! plugin/textobj/comment.vim

let g:maps = { 'ac': '<Plug>(textobj-comment-a)',
             \ 'ic': '<Plug>(textobj-comment-i)',
             \ 'aC': '<Plug>(textobj-comment-big-a)' }

describe 'plugin'

  it 'loaded'
    Expect exists('g:loaded_textobj_comment') == 1
  end

end

describe '<Plug> mappings'

  it 'defined in proper modes'
    for pm in values(g:maps)
      Expect maparg(pm, 'n')     == ''
      Expect maparg(pm, 'v') not == ''
      Expect maparg(pm, 'o') not == ''
      Expect maparg(pm, 'i')     == ''
      Expect maparg(pm, 'c')     == ''
    endfor
  end

end

describe 'default key mappings'

  it 'defined in proper modes'
    for [km, pm] in items(g:maps)
      Expect maparg(km, 'n') ==# ''
      Expect maparg(km, 'v') ==# pm
      Expect maparg(km, 'o') ==# pm
      Expect maparg(km, 'i') ==# ''
      Expect maparg(km, 'c') ==# ''
    endfor
  end

end

describe ':TextobjCommentDefaultKeyMappings'

  it 'defined'
    Expect exists(':TextobjCommentDefaultKeyMappings') == 2
  end

  it 'restores default key mappings'
    for km in keys(g:maps)
      exe 'unmap' km
    endfor
    Expect map(keys(g:maps), 'maparg(v:val, "ov")') == ['', '', '']
    TextobjCommentDefaultKeyMappings
    for [km, pm] in items(g:maps)
      Expect maparg(km, 'n') ==# ''
      Expect maparg(km, 'v') ==# pm
      Expect maparg(km, 'o') ==# pm
      Expect maparg(km, 'i') ==# ''
      Expect maparg(km, 'c') ==# ''
    endfor
  end

end
