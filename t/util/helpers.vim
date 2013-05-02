" Selection helpers

function! DoSelect(cmd)
  exe 'normal' a:cmd
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

function! SelectABigComment(...)
  return DoSelect(a:0 ? a:1 : "v\<Plug>(textobj-comment-big-a)\<Esc>")
endfunction

" Custom matchers

function! ToHavePositions(actual, pos1, pos2)
  return a:actual[0] == a:pos1 && a:actual[1] == a:pos2
endfunction

function! ToHaveLineNumbers(actual, lnum1, lnum2)
  return a:actual[0][0] == a:lnum1 && a:actual[1][0] == a:lnum2
endfunction

function! ToHaveColumns(actual, col1, col2)
  return a:actual[0][1] == a:col1 && a:actual[1][1] == a:col2
endfunction

function! LineNumbersFailureMessage(actual, lnum1, lnum2)
  return FailureMessage(a:actual, a:lnum1, a:lnum2, 0)
endfunction

function! ColumnsFailureMessage(actual, col1, col2)
  return FailureMessage(a:actual, a:col1, a:col2, 1)
endfunction

function! FailureMessage(actual, arg1, arg2, posidx)
  return [ '  Actual value: ' . string(map(copy(a:actual), 'v:val['.a:posidx.']')),
         \ 'Expected value: ' . string([a:arg1, a:arg2]) ]
endfunction

call vspec#customize_matcher('to_have_pos', {'match': function('ToHavePositions')})
call vspec#customize_matcher('to_have_lnums', {
     \   'match': function('ToHaveLineNumbers'),
     \   'failure_message_for_should': function('LineNumbersFailureMessage'),
     \   'failure_message_for_should_not': function('LineNumbersFailureMessage')
     \ })
call vspec#customize_matcher('to_have_cols', {
     \   'match': function('ToHaveColumns'),
     \   'failure_message_for_should': function('ColumnsFailureMessage'),
     \   'failure_message_for_should_not': function('ColumnsFailureMessage')
     \ })
