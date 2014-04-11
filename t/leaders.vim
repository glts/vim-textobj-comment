runtime! plugin/textobj/comment.vim
runtime! autoload/textobj/comment.vim

silent filetype plugin indent on
syntax enable

function! SID()
  redir => scripts
  silent scriptnames
  redir END
  for line in split(scripts, '\n')
    let [_0, sid, path; _] = matchlist(line, '^\s*\(\d\+\):\s*\(.*\)$')
    if path =~# 'autoload/textobj/comment\.vim$'
      return '<SNR>' . sid . '_'
    endif
  endfor
endfunction

call vspec#hint({'sid': 'SID()'})

describe '''comments'' and ''commentstring'''

  it 'default settings'
    Expect &comments ==# 's1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-'
    Expect &commentstring ==# '/*%s*/'
  end

  it 'set for filetype'
    silent tabedit Abc.java
    Expect &comments ==# 'sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-'
    Expect &commentstring ==# '//%s'
    bwipeout
  end

end

describe 's:GetLeaders()'

  before
    silent tabedit abc.unknown
  end

  after
    bwipeout
  end

  it 'parses default ''comments'' setting'
    Expect len(Call('s:GetLeaders')) == 2
    Expect Call('s:GetLeaders')[0] == ['//', '#', '%', 'XCOMM', '>']
    Expect Call('s:GetLeaders')[1] == [['/*', '*/']]
    Expect filter(Call('s:GetLeaders')[1], 'len(v:val)!=2') == []
  end

  it 'falls back on ''commentstring'' setting'
    set comments=
    Expect Call('s:GetLeaders') == [[], [['/*', '*/']]]
    set commentstring=;;\ %s
    Expect Call('s:GetLeaders') == [[';;'], []]
  end

  it 'handles empty ''comments'' and ''commentstring'' settings'
    set comments=
    set commentstring=
    Expect Call('s:GetLeaders') == [[], []]
  end

end

describe 's:GetSimpleLeaders()'

  it 'returns the simple leaders'
    let leaders = [['bO', '; '], ['s', '{-'], ['e', '-}'], ['', '--']]
    Expect Call('s:GetSimpleLeaders', leaders) == ['; ', '--']
  end

  it 'accepts empty list'
    Expect Call('s:GetSimpleLeaders', []) == []
  end

end

describe 's:GetPairedLeaders()'

  it 'returns the paired leaders'
    let leaders = [['bO', '; '], ['s1', '{-'], ['e', '-}'], ['', '--'], ['sO', '<'], ['ex', '>']]
    Expect Call('s:GetPairedLeaders', leaders) == [['{-', '-}'], ['<', '>']]
  end

  it 'ignores invalid pairs'
    let leaders = [['s', '{{'], ['s', '[['], ['e', ']]'], ['e', '>']]
    Expect Call('s:GetPairedLeaders', leaders) == [['[[', ']]']]
  end

  it 'accepts empty list'
    Expect Call('s:GetPairedLeaders', []) == []
  end

end
