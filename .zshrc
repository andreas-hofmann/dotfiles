# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="essembeh"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable command auto-correction.
# DISABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
    compleat
    gnu-utils
    #sudo
    vi-mode
    terminfo
    history-substring-search
    cp
    copydir
    copyfile
    common-aliases
    colorize
    git
    #ruby
    python
    systemd
    screen
    pip
    django
    postgres
    #rsync
    svn
    command-not-found
    debian
    archlinux
)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'
if [[ -n $DISPLAY ]]; then
  alias vi='gvim &> /dev/null'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

#
# Self-defined stuff starts here
#

# Colored output for less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Aliases
alias ls='ls --color=auto -lh'
alias la='ls --color=auto -lha'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'

alias asdf='setxkbmap de adnw'
alias hiea='setxkbmap de neoqwertz'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Recursive history search
# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
# same for ubuntu
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Recursive searching through history
bindkey '^R' history-incremental-search-backward
bindkey '^F' history-incremental-search-forward

# Restore default ALT+. behaviour
bindkey '\e.' insert-last-word

# Override some prompt settings of essembeh theme
ZSH_THEME_COLOR_USER="green" 
ZSH_THEME_COLOR_HOST="green" 
ZSH_THEME_COLOR_AT="grey" 
ZSH_THEME_COLOR_PWD="yellow" 
ZSH_THEME_COLOR_END="grey" 
ZSH_THEME_COLOR_CLOCK="yellow"
test -n "$SSH_CONNECTION" && ZSH_THEME_COLOR_HOST="red"
test `id -u` = 0 && ZSH_THEME_COLOR_USER="red"

PS1='%{$fg_bold[$ZSH_THEME_COLOR_USER]%}%n%{$fg_bold[$ZSH_THEME_COLOR_AT]%}@%{$fg_bold[$ZSH_THEME_COLOR_HOST]%}%M%{$reset_color%} %{$fg_bold[$ZSH_THEME_COLOR_PWD]%}%~%{$reset_color%} $(my_git_prompt_info)%{$fg_bold[$ZSH_THEME_COLOR_END]%}%(!.#.$) %{$reset_color%}'
RPS1="${return_code} %{$fg[$ZSH_THEME_COLOR_CLOCK]%}%D{[%H:%M:%S]}%{$reset_color%}"

# Autocomplete for ..
zstyle ':completion:*' special-dirs true

### Stuff taken from the grml zsh default config ###

# use the vi navigation keys (hjkl) besides cursor keys in menu completion
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

# press ctrl-q to quote line:
mquote () {
      zle beginning-of-line
      zle forward-word
      # RBUFFER="'$RBUFFER'"
      RBUFFER=${(q)RBUFFER}
      zle end-of-line
}
zle -N mquote && bindkey '^q' mquote

## warning if file exists ('cat /dev/null > ~/.zshrc')
setopt NO_clobber

# Fix key bindings

bindkey "${terminfo[kich1]}" overwrite-mode
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kpp]}" up-line-or-history
bindkey "${terminfo[kdch1]}" delete-char
bindkey "${terminfo[kend]}" end-of-line
bindkey "${terminfo[knp]}" down-line-or-history
bindkey "${terminfo[kcub1]}" backward-char
bindkey "${terminfo[kcuf1]}" forward-char
#bindkey "${terminfo[kcuu1]}" up-line-or-search
#bindkey "${terminfo[kcud1]}" down-line-or-search

## aliases ##

## get top 10 shell commands:
alias top10='print -l ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

# Switching shell safely and efficiently? http://www.zsh.org/mla/workers/2001/msg02410.html
bash() {
    NO_SWITCH="yes" command bash "$@"
}
restart () {
    exec $SHELL $SHELL_ARGS "$@"
}

# Find out which libs define a symbol
lcheck() {
    if [[ -n "$1" ]] ; then
        nm -go /usr/lib/lib*.a 2>/dev/null | grep ":[[:xdigit:]]\{8\} . .*$1"
    else
        echo "Usage: lcheck <function>" >&2
    fi
}

# Download a file and display it locally
uopen() {
    emulate -L zsh
    if ! [[ -n "$1" ]] ; then
        print "Usage: uopen \$URL/\$file">&2
        return 1
    else
        FILE=$1
        MIME=$(curl --head $FILE | \
               grep Content-Type | \
               cut -d ' ' -f 2 | \
               cut -d\; -f 1)
        MIME=${MIME%$'\r'}
        curl $FILE | see ${MIME}:-
    fi
}

# print hex value of a number
hex() {
    emulate -L zsh
    if [[ -n "$1" ]]; then
        printf "%x\n" $1
    else
        print 'Usage: hex <number-to-convert>'
        return 1
    fi
}

# Add the nix package manager
if [ -d ~/.nix-profile ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
fi

# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
if type -p dircolors >/dev/null ; then
	if [[ -f ~/.dir_colors ]] ; then
		eval $(dircolors -b ~/.dir_colors)
	elif [[ -f /etc/DIR_COLORS ]] ; then
		eval $(dircolors -b /etc/DIR_COLORS)
	fi
fi

# better yaourt colors
export YAOURT_COLORS="nb=1:pkg=1:ver=1;32:lver=1;45:installed=1;42:grp=1;34:od=1;41;5:votes=1;44:dsc=0:other=1;35"
