set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required
" install plugins: Launch vim and run :PluginInstall
"
Plugin 'tpope/vim-fugitive' " plugin on GitHub repo
Plugin 'vim-python/python-syntax' "https://github.com/vim-python/python-syntax
let g:python_highlight_all = 1
Plugin 'w0rp/ale'
Plugin 'tpope/vim-unimpaired.git' " some great key bindings like quickfix nav
Plugin 'ervandew/supertab.git' " allow tab completion
Plugin 'reasonml-editor/vim-reason-plus' " https://github.com/reasonml-editor/vim-reason-plus
Plugin 'keith/swift.vim.git' " https://github.com/keith/swift.vim
Plugin 'craigemery/vim-autotag'
if has('conceal')
  Plugin 'Yggdroot/indentLine' " display vertical lines at each indentation level
endif

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on   " required, load filetype-specific intend files
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" ALE (below settings make ale only run when a file is saved)
let g:ale_lint_on_enter = 0 " disable ale from running when a file is opened
let g:ale_lint_on_text_changed = 'never' " disable ale from running when text is changed
let g:ale_lint_on_save = 1 " set ale to run when a file is saved
" stifles errors for libraries (eg boto3) not yet in typeshed
let g:ale_python_mypy_options = '--ignore-missing-imports' " mypy --ignore-missing imports
if filereadable("etc/pylintrc")
  let g:ale_python_pylint_options="--rcfile=etc/pylintrc"
endif

syntax on " turn syntax highlighting on
colorscheme darcula
set number " show line numbers
set showcmd " show commands in bottom right
set showmatch " highlight matching [{(
set cursorline " highlight current line
set ruler " show current line number and line count 
set hls is " set highlight search and inline highlighting when typing a search
set hidden " leave file unsaved in current buffer
set grepprg=ack " have grep use ack behind the scenes. install ack first: brew install ack
set laststatus=2 " always show the vim status line
set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%y\ %-25.(L:%l,\ C:%c%V,\ Hex:%B%)\ %P " default status line with:
set backspace=2 " make backspace work like most other programs
" current git branch name added via fugitive, line/column number, current character hex value
set spell spelllang=en_us " set spell checking :)

" map backspace and return to move faster in a file
nnoremap <BS> {
onoremap <BS> {
vnoremap <BS> {

nnoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
onoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
vnoremap <CR> }
