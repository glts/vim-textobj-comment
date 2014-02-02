" textobj-comment - Text objects for comments
" Author: glts <676c7473@gmail.com>
" Date: 2013-11-15
" Version: 1.0.0
" GetLatestVimScripts: 2100 1 textobj-user
" GetLatestVimScripts: 4570 1 :AutoInstall: textobj-comment

if exists('g:loaded_textobj_comment')
  finish
endif

if exists(':NeoBundleDepends') == 2
  NeoBundleDepends 'kana/vim-textobj-user'
endif

call textobj#user#plugin('comment', {
     \   '-': {
     \     'select-a-function': 'textobj#comment#select_a',
     \     'select-a': get(g:, 'textobj_outer_comment_key', 'ac'),
     \     'select-i-function': 'textobj#comment#select_i',
     \     'select-i': get(g:, 'textobj_inner_comment_key', 'ic'),
     \   },
     \   'big': {
     \     'select-a-function': 'textobj#comment#select_big_a',
     \     'select-a': get(g:, 'textobj_outer_Comment_key', 'aC'),
     \   }
     \ })

let g:loaded_textobj_comment = 1
