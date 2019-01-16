set nocompatible " be iMproved, required
filetype off " required

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
Plugin 'pangloss/vim-javascript' " https://github.com/pangloss/vim-javascript
Plugin 'mxw/vim-jsx' " https://github.com/mxw/vim-jsx
if has('conceal')
  Plugin 'Yggdroot/indentLine' " display vertical lines at each indentation level
endif

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on   " required, load filetype-specific intend files
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief vundle help
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

let g:ale_open_list = 1 " show ale errors/warnings in quickfix

let g:jsx_ext_required = 0 " Allow JSX in normal JS files

let g:indentLine_fileTypeExclude = ['json'] " don't conceal json files

if !exists("g:syntax_on")
    syntax enable " turn syntax highlighting on
endif
colorscheme darcula
set number " show line numbers
set wrap lbr "wrap whole words instead of breaking words up
set showcmd " show commands in bottom right
set showmatch " highlight matching [{(
set cursorline " highlight current line
set ruler " show current line number and line count 
set hls is " set highlight search and inline highlighting when typing a search
set hidden " leave file unsaved in current buffer
set grepprg=ack " have grep use ack behind the scenes. install ack first: brew install ack
set backspace=2 " make backspace work like most other programs
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab " use 4 spaces everywhere
set wildmenu " visual autocomplete for command menu
set spell spelllang=en_us " set spell checking :)
set t_ti= t_te= " show results from terminal commands within vim!

" Show fugitive Gdiff in vertical windows
set diffopt+=vertical

" Set up statusline
set laststatus=2 " always show the vim status line
set statusline+=%{fugitive#statusline()}
set statusline+=%= " separate left status from right
set statusline+=\ %y " file type
set statusline+=\ L:%l,\ C:%c%V,\ Hex:%B " line, column, hex value under cursor
set statusline+=\ %P " percent through file

" turn off highlighting
autocmd BufNewFile,BufRead *.markdown syn match markdownIgnore "_"
autocmd BufNewFile,BufRead *.markdown syn match markdownIgnore "*"
autocmd BufNewFile,BufRead *.md syn match markdownIgnore "_"
autocmd BufNewFile,BufRead *.md syn match markdownIgnore "*"

nmap <silent> <C-j> <Plug>(ale_next_wrap) " next ale error

let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"
