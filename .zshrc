# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use grmls zshrc + antigen.

# {{{ functions

# Initial setup for zshrcs. Runs in a subshell.
function bootstrap {
	(

	cd $HOME

	mkdir -p .zsh

	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.zlogout 

	cd $HOME/.zsh

	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.zsh/zshrc.local
	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.zsh/zshrc.antigen

	curl -L https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc > ${HOME}/.zsh/zshrc.grml
	curl -L git.io/antigen > ${HOME}/.zsh/antigen.zsh

	)
}

# }}}

# {{{ Source the individual configs.

if [ ! -r "${HOME}/.zsh/zshrc.local" ] ; then
	echo " zsh not set up. Call bootstrap()!"
else
	source ${HOME}/.zsh/zshrc.grml

	prompt off

	source ${HOME}/.zsh/zshrc.antigen

	source ${HOME}/.zsh/zshrc.local

	if [ -x /usr/bin/direnv ]; then
		eval "$(/usr/bin/direnv hook zsh)"
	fi
fi
 
# }}}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
