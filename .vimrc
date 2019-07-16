
" --- Terminal ---------------------------------------------
set nocompatible
set term=xterm
set mouse=""                    " Disable use of the mouse

" --- Options ----------------------------------------------
set tabstop=4                   " Size of a hard tabstop (ts)
set shiftwidth=4                " Size of an indentation (sw)
set softtabstop=0               " Number of spaces a <Tab> counts for. When 0, featuer is off (sts)
set noexpandtab                 " Always uses tabs instead of space characters (noet)
set autoindent                  " Copy indent from current line when starting a new line (ai)

set backspace=indent,eol,start
set showmatch                   " Highlight matching [{()}]
set ruler                       " Display the cursor position on the last line of the screen

set hlsearch                    " Highlight matches for search
set incsearch                   " Search as characters are entered
set ignorecase                  " Use case insensitive search...
set smartcase                   " ...except when using capital letters

" --- Binding ----------------------------------------------
nnoremap <Tab> >>|              " Command mode: indent right
nnoremap <S-Tab> <<|            " Command mode: indent left
"noremap <LeftRelease> "+y<LeftRelease>gv| " Left mouse click copies selection

" --- Visual -----------------------------------------------
syntax on                       " Enable syntax highlighting
set bg=dark

