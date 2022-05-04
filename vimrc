" =====================
" Vundle (setup start)
" =====================
"
" Brief Vundle help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

" see :h vundle for more details or wiki for FAQ

set nocompatible " be iMproved, required
filetype off " required
set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize

call vundle#begin()

Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required
Plugin 'tpope/vim-fugitive' " plugin on GitHub repo
Plugin 'vim-python/python-syntax' "https://github.com/vim-python/python-syntax
let g:python_highlight_all = 1
Plugin 'w0rp/ale'
Plugin 'tpope/vim-unimpaired.git' " some great key bindings like quickfix nav
Plugin 'tpope/vim-vinegar' " https://github.com/tpope/vim-vinegar
Plugin 'ervandew/supertab.git' " allow tab completion
Plugin 'craigemery/vim-autotag'
if has('conceal')
  Plugin 'Yggdroot/indentLine' " display vertical lines at each indentation level
endif

" Languages
Plugin 'keith/swift.vim.git' " https://github.com/keith/swift.vim
Plugin 'pangloss/vim-javascript' " https://github.com/pangloss/vim-javascript
Plugin 'elixir-editors/vim-elixir' "https://github.com/elixir-editors/vim-elixir
Plugin 'leafgarland/typescript-vim' " https://github.com/leafgarland/typescript-vim
Plugin 'dart-lang/dart-vim-plugin' " https://github.com/dart-lang/dart-vim-plugin
Plugin 'mxw/vim-jsx' " https://github.com/mxw/vim-jsx
Plugin 'Zaptic/elm-vim'

" Language server protocol support (per https://github.com/prabirshrestha/vim-lsp)
Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'

" All of your Plugins must be added before the following line
call vundle#end() " required

filetype plugin indent on " required, load filetype-specific intend files
" To ignore plugin indent changes, instead use:
"filetype plugin on

" ==============================================
" Vundle (setup end)
" Put your non-Plugin stuff after this line
" ==============================================


colorscheme darcula

" set the <Leader> and <LocalLeader> to be the space bar
let mapleader="\<Space>"
let maplocalleader="\<Space>"

" map {space bar + o} to open current buffer directory
nnoremap <Leader>o :!open %:h<cr>

set number " show line numbers
set wrap lbr " wrap whole words instead of breaking words up
set autoindent " Copy indent from current line when starting an new line (works nicely with format option `n` for lists)
set showcmd " show commands in bottom right
set showmatch " highlight matching [{(
set cursorline " highlight current line
set ruler " show current line number and line count 
set hls is " set highlight search and inline highlighting when typing a search
set hidden " leave file unsaved in current buffer
" have grep use ack behind the scenes. install ack first: brew install ack
" also ignore dist file which is a frontend autogenerated directory
set grepprg=ack\ --ignore-dir=dist\ --ignore-file=is:tags
set backspace=2 " make backspace work like most other programs
set wildmenu " visual autocomplete for command menu
set spell spelllang=en_us " set spell checking :)
set spellfile=~/.vim/spell/en.utf-8.add " set spell file
set t_ti= t_te= " show results from terminal commands within vim!
set ignorecase " ignore case when searcing with `/`. use `/\C` for case sensitive search

" search down into subfolders
" provides tab-completion for all file-related tasks
" 
" can use `:find <name>` to quickly find a file with partial name
set path+=** 

" Set spacing
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd Filetype ruby setlocal softtabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype javascript setlocal softtabstop=2 shiftwidth=2 softtabstop=2

" Set up statusline
set laststatus=2 " always show the vim status line
set statusline+=%{fugitive#statusline()}
set statusline+=%= " separate left status from right
set statusline+=\ %y " file type
set statusline+=\ L:%l,\ C:%c%V,\ Hex:%B " line, column, hex value under cursor
set statusline+=\ %P " percent through file

" -- ALE --
" Below make ale only run when a file is saved)
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

" next ale error
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" turn off highlighting markdown
autocmd BufNewFile,BufRead *.markdown syn match markdownIgnore "_"
autocmd BufNewFile,BufRead *.markdown syn match markdownIgnore "*"
autocmd BufNewFile,BufRead *.md syn match markdownIgnore "_"
autocmd BufNewFile,BufRead *.md syn match markdownIgnore "*"

" -- Swift --
" connect to the swift source kit lsp
if executable('sourcekit-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'sourcekit-lsp',
        \ 'cmd': {server_info->['sourcekit-lsp']},
        \ 'whitelist': ['swift'],
        \ })
endif

" -- Dart --
let dart_format_on_save = 1 " run :DartFmt on save
let dart_style_guide = 2 " enabled style guide syntax (like 2-space indentation)

if !exists("g:syntax_on")
    syntax enable " turn syntax highlighting on
endif

if executable('dart_language_server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'dart_language_server',
        \ 'cmd': {server_info->['dart_language_server']},
        \ 'whitelist': ['dart'],
        \ })
    nnoremap <Leader>d :LspHover<cr>
endif

function! HotReload() abort
  if !empty(glob("/tmp/flutter.pid"))
    silent execute '!kill -SIGUSR1 "$(cat /tmp/flutter.pid)"'
  endif
endfunction
autocmd BufWritePost *.dart call HotReload()


