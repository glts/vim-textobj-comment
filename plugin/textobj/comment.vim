" textobj-comment - Text objects for comments
" Author: glts <676c7473@gmail.com>
" Date: 2013-04-21
" GetLatestVimScripts: 2100 1 textobj-user
" GetLatestVimScripts: 0 0 :AutoInstall: textobj-comment

if exists('g:loaded_textobj_comment')
  finish
endif

call textobj#user#plugin('comment', {
     \   '-': {
     \     'select-a-function': 'textobj#comment#select_a',
     \     'select-a': 'ac',
     \     'select-i-function': 'textobj#comment#select_i',
     \     'select-i': 'ic',
     \   },
     \   'inside': {
     \     'select-i-function': 'textobj#comment#select_inside_i',
     \     'select-i': 'iC',
     \   }
     \ })

let g:loaded_textobj_comment = 1