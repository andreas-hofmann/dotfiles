scriptencoding utf-8
" ^^ Please leave the above line at the start of the file.

" Default configuration file for Vim
" $Header: /var/cvsroot/gentoo-x86/app-editors/vim-core/files/vimrc-r3,v 1.1 2006/03/25 20:26:27 genstef Exp $

" Written by Aron Griffis <agriffis@gentoo.org>
" Modified by Ryan Phillips <rphillips@gentoo.org>
" Modified some more by Ciaran McCreesh <ciaranm@gentoo.org>
" Added Redhat's vimrc info by Seemant Kulleen <seemant@gentoo.org>

" You can override any of these settings on a global basis via the
" "/etc/vim/vimrc.local" file, and on a per-user basis via "~/.vimrc". You may
" need to create these.

" {{{ Setup cache dir
let cachedir=expand('~/.cache/vim')

if !isdirectory(cachedir)
   call mkdir(cachedir, "p", 0700)
endif
" }}}

"" {{{ Fetch + source the grml vimrc
let grmlrc=expand('~/.vimrc.grml')
if !filereadable(grmlrc)
    echo "Fetching zshrc.grml..."
    echo ""
    silent !curl -L https://github.com/andreas-hofmann/dotfiles/raw/master/.vimrc.grml > ~/.vimrc.grml
endif

if filereadable(grmlrc)
    source ~/.vimrc.grml
endif
" }}}

" {{{ Setting up Vundle - the vim plugin bundler

let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')

if !filereadable(vundle_readme) 
    echo "Installing Vundle.."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
    let iCanHazVundle=0
endif

set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim/

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Own bundles start here...
Plugin 'Syntastic'
Plugin 'https://github.com/tpope/vim-speeddating'
Plugin 'https://github.com/tpope/vim-repeat'
Plugin 'https://github.com/tpope/vim-surround'
Plugin 'https://github.com/kien/ctrlp.vim'
Plugin 'https://github.com/Yggdroot/indentLine'

if iCanHazVundle == 0
    echo "Installing Vundles, please ignore key map error messages"
    echo ""
    :PluginInstall
endif

call vundle#end() 

filetype plugin indent on " load filetype plugins/indent settings

" }}}

" {{{ Modeline settings
" We don't allow modelines by default. See bug #14088 and bug #73715.
" If you're not concerned about these, you can enable them on a per-user
" basis by adding "set modeline" to your ~/.vimrc file.
set nomodeline
" }}}

" {{{ Locale settings

" If we have a BOM, always honour that rather than trying to guess.
if &fileencodings !~? "ucs-bom"
  set fileencodings^=ucs-bom
endif

" Always check for UTF-8 when trying to determine encodings.
if &fileencodings !~? "utf-8"
  set fileencodings+=utf-8
endif

" Make sure we have a sane fallback for encoding detection
set fileencodings+=default
" }}}

" {{{ Syntax highlighting settings
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
endif
" }}}

" {{{ Terminal fixes
if &term ==? "xterm"
  set t_Sb=^[4%dm
  set t_Sf=^[3%dm
  set ttymouse=xterm2
endif

if &term ==? "gnome" && has("eval")
  " Set useful keys that vim doesn't discover via termcap but are in the
  " builtin xterm termcap. See bug #122562. We use exec to avoid having to
  " include raw escapes in the file.
  exec "set <C-Left>=\eO5D"
  exec "set <C-Right>=\eO5C"
endif
" }}}

" {{{ Filetype plugin settings
" Enable plugin-provided filetype settings, but only if the ftplugin
" directory exists (which it won't on livecds, for example).
if isdirectory(expand("$VIMRUNTIME/ftplugin"))
  filetype plugin on

  " Uncomment the next line (or copy to your ~/.vimrc) for plugin-provided
  " indent settings. Some people don't like these, so we won't turn them on by
  " default.
  filetype indent on
endif
" }}}

" {{{ Fix &shell, see bug #101665.
if "" == &shell
  if executable("/bin/bash")
    set shell=/bin/bash
  elseif executable("/bin/sh")
    set shell=/bin/sh
  endif
endif
"}}}

" {{{ Our default /bin/sh is bash, not ksh, so syntax highlighting for .sh
" files should default to bash. See :help sh-syntax and bug #101819.
if has("eval")
  let is_bash=1
endif
" }}}

" {{{ Autocommands
if has("autocmd")

augroup gentoo
  au!

  " Gentoo-specific settings for ebuilds.  These are the federally-mandated
  " required tab settings.  See the following for more information:
  " http://www.gentoo.org/proj/en/devrel/handbook/handbook.xml
  " Note that the rules below are very minimal and don't cover everything.
  " Better to emerge app-vim/gentoo-syntax, which provides full syntax,
  " filetype and indent settings for all things Gentoo.
  au BufRead,BufNewFile *.e{build,class} let is_bash=1|setfiletype sh
  au BufRead,BufNewFile *.e{build,class} set ts=4 sw=4 noexpandtab

  " In text files, limit the width of text to 78 characters, but be careful
  " that we don't override the user's setting.
  autocmd BufNewFile,BufRead *.txt
        \ if &tw == 0 && ! exists("g:leave_my_textwidth_alone") |
        \     setlocal textwidth=78 |
        \ endif

  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
        \ if ! exists("g:leave_my_cursor_position_alone") |
        \     if line("'\"") > 0 && line ("'\"") <= line("$") |
        \         exe "normal g'\"" |
        \     endif |
        \ endif

  " When editing a crontab file, set backupcopy to yes rather than auto. See
  " :help crontab and bug #53437.
  autocmd FileType crontab set backupcopy=yes

augroup END

"Python Stuff goes here:
autocmd BufRead *.py set tabstop=4
autocmd BufRead *.py set shiftwidth=4
autocmd BufRead *.py set smarttab
autocmd BufRead *.py set expandtab
autocmd BufRead *.py set softtabstop=4
autocmd BufRead *.py set autoindent
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``

"Ruby stuff goes here:
autocmd BufRead *.rb set tabstop=2
autocmd BufRead *.rb set shiftwidth=2
autocmd BufRead *.rb set smarttab
autocmd BufRead *.rb set expandtab
autocmd BufRead *.rb set softtabstop=2
autocmd BufRead *.rb set autoindent

"Tex Stuff goes here:
autocmd BufRead *.tex set tabstop=4
autocmd BufRead *.tex set shiftwidth=4
autocmd BufRead *.tex set smarttab
autocmd BufRead *.tex set expandtab
autocmd BufRead *.tex set softtabstop=4
autocmd BufRead *.tex set autoindent
"
"html stuff goes here:
autocmd BufRead *.html set tabstop=2
autocmd BufRead *.html set shiftwidth=2
autocmd BufRead *.html set smarttab
autocmd BufRead *.html set expandtab
autocmd BufRead *.html set softtabstop=2
autocmd BufRead *.html set autoindent

"htmldjango stuff goes here:
autocmd BufRead *.htmldjango set filetype=htmldjango
autocmd BufRead *.htmldjango set tabstop=2
autocmd BufRead *.htmldjango set shiftwidth=2
autocmd BufRead *.htmldjango set smarttab
autocmd BufRead *.htmldjango set expandtab
autocmd BufRead *.htmldjango set softtabstop=2
autocmd BufRead *.htmldjango set autoindent

endif " has("autocmd")
" }}}

" {{{ .swp
set backupdir=~/.cache/vim/swp

let targetdir=expand('~/.cache/vim/swp')
if isdirectory(targetdir) != 1 && getftype(targetdir) == "" && exists("*mkdir")
    call mkdir(targetdir, "p", 0700)
endif
" }}}

" {{{ Tweak tab navigation
noremap <C-h> gT
noremap <C-l> gt
map <C-t> <Esc>:tabnew .<CR>
" }}}

" {{{ General settings

set nocompatible        " Use Vim defaults (much better!)
set bs=2                " Allow backspacing over everything in insert mode
set ai                  " Always set auto-indenting on
set history=1000         " keep 50 lines of command history
set ruler               " Show the cursor position all the time

"Set colorscheme
colorscheme ron

"set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hlsearch            " Highlight search results
"set hidden             " Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)
set nocp		" Less compatibility

set listchars=trail:~,eol:$,nbsp:_,tab:>\      "

set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%c\",getftime(expand(\"%:p\")))}%=\ lin:%l\,%L\ col:%c%V\ pos:%o\ ascii:%b\ %P
set laststatus=2

set number

" enable mouse
set mousemodel=extend

set viminfo='20,\"500   " Keep a .viminfo file.

" Don't use Ex mode, use Q for formatting
map Q gq

" When doing tab completion, give the following files lower priority. You may
" wish to set 'wildignore' to completely ignore files, and 'wildmenu' to enable
" enhanced tab completion. These can be done in the user vimrc file.
set suffixes+=.info,.aux,.log,.dvi,.bbl,.out,.o,.lo

" When displaying line numbers, don't use an annoyingly wide number column. This
" doesn't enable line numbers -- :set number will do that. The value given is a
" minimum width to use for the number column, not a fixed size.
if v:version >= 700
  set numberwidth=3
endif
" }}}

let g:changelog_username="Andreas Hofmann <mail@andreas-hofmann.org>"
set foldmethod=marker

" vim: set fenc=utf-8 sw=4 sts=4 et foldmethod=marker :
