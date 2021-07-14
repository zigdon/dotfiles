if filereadable($HOME . "/.dotfiles/vimrc")
  source $HOME/.dotfiles/vimrc
endif

" UTF-8 is now
set encoding=utf8

" Default to unix EOLs, but handle others gracefully
set ffs=unix,dos,mac

" Don't try to redraw in the middle of a macro
set lazyredraw

" 256 colors and syntax highlighting
set t_Co=256

" Color scheme
set bg=dark
syntax on

set ruler

" Have the mouse work
set mouse=a

" Set 'tabstop' and 'shiftwidth' to whatever you prefer and use
" 'expandtab'.  This way you will always insert spaces.  The
" formatting will never be messed up when 'tabstop' is changed.
set tabstop=4
set softtabstop=2
set shiftwidth=2
set shiftround
set expandtab
set autoindent
set smartindent
set report=1
set hidden
set backspace=indent,eol,start
set incsearch
set showmatch
set ignorecase smartcase
set matchpairs+=<:>
set foldmethod=indent
set foldcolumn=5
set modeline

" Ignore compiled files when completing paths
set wildignore=*.o,*~,*.pyc,*.pyo,*.class,*.hi

" File type detection
filetype on
filetype plugin on

" KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""""
function! CleverTab()
  if strpart( getline('.'), col('.')-2, 1 ) =~ '\s' || col('.') == 1
    return "\<Tab>"
  else
    return "\<C-N>"
  endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" Use the \ key for extra key combos
let mapleader = "\\"
let g:mapleader = "\\"

" \m = remove carriage returns (dos2unix)
noremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" \ss = toggle spell check
nmap <leader>ss :setlocal spell!<cr>

" \g = toggle gitgutter
nmap <leader>g :GitGutterLineHighlightsToggle<cr>

" escape insert mode
inoremap jk <esc>
inoremap kj <esc>

" PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""

" Load pathogen: https://github.com/tpope/vim-pathogen
if filereadable($HOME . "/.vim/autoload/pathogen.vim")
  call pathogen#infect($HOME . '/.vim/bundle')
endif

" Tree viewer init
function! NERDinit()
  " Nothing to do if we don't have NERDTree
  if exists(":NERDTree")
    " launch the filetree browser if started without files
    if !argc()
      NERDTree
    endif
    noremap <leader>T NERDTreeToggle
  endif
endfunction

" no need to leaderleader
let g:EasyMotion_leader_key = '<leader>'

" TRIGGERED ACTIONS
""""""""""""""""""""""""""""""""""""""""""""""""""

" Remember info about open buffers on close...
set viminfo^=%

" Delete trailing whitespace on save in .py files
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

" AUTOCMDs
""""""""""""""""""""""""""""""""""""""""""""""""""
" put all autocmds here, to avoid repeated invocations

if !exists("autocommands_loaded")
  " Automatically reload .vimrc when it is saved
  autocmd BufWritePost $MYVIMRC source $MYVIMRC

  " Allow for highlighting columns beyond some threshold:
  highlight OverLength ctermfg=red guifg=red
  autocmd FileType python
      \ setlocal indentexpr=GetGooglePythonIndent(v:lnum)
      \ | setlocal omnifunc=pythoncomplete#Complete
      \ | match OverLength /\%>80v.\+/

  " Strip trailing whitespace
  autocmd BufWrite *.py :call DeleteTrailingWS()
  " return to last edit position when opening files
  autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
  " Bind NERDTree
  autocmd vimenter * :call NERDinit()

  " Paste mode persists by default.  I don't recall ever *wanting* this to
  " happen, but I *do* sometimes get burned by this.  The following autocommand
  " prevents this from happening
  autocmd InsertLeave * set nopaste

  autocmd BufReadPost *.tsx setlocal syntax=typescript

  let autocommands_loaded = 1
endif
