# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Set the base config.
# Allow using oh-my-zsh and/or grmls zsh config as base.

USE_GRML_ZSHRC=1
USE_OMZ_ZSHRC=0
USE_ANTIGEN=1

if [ $USE_GRML_ZSHRC -eq 1 -a -f ${HOME}/.zsh/zshrc.grml ]; then
	source ${HOME}/.zsh/zshrc.grml
fi

if [ $USE_GRML_ZSHRC -eq 1 ]; then
	if [ $USE_ANTIGEN -eq 1 -o $USE_OMZ_ZSHRC -eq 1 ]; then
		prompt off
	fi
fi

if [ $USE_OMZ_ZSHRC -eq 1 -a -f ${HOME}/.zsh/zshrc.oh-my-zsh ]; then
	source ${HOME}/.zsh/zshrc.oh-my-zsh
fi

if [ $USE_ANTIGEN -eq 1 -a -f ${HOME}/.zsh/zshrc.antigen ]; then
	source ${HOME}/.zsh/zshrc.antigen
fi

if [ -f ${HOME}/.zsh/zshrc.local ]; then
	source ${HOME}/.zsh/zshrc.local
fi

if [ -x /usr/bin/direnv ]; then
	eval "$(/usr/bin/direnv hook zsh)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
