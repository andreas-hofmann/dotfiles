### zshrc

## Set the base config.
# Allow using oh-my-zsh and/or grmls zsh config as base.

USE_GRML_ZSHRC=1
USE_OMZ_ZSHRC=1

if [ $USE_GRML_ZSHRC -eq 1 -a -f ~/zsh/.zshrc.grml ]; then
	source ~/.zsh/zshrc.grml
fi

if [ $USE_GRML_ZSHRC -eq 1 -a $USE_OMZ_ZSHRC -eq 1 ]; then
	prompt off
fi

if [ $USE_OMZ_ZSHRC -eq 1 -a -f ~/.zsh/zshrc.oh-my-zsh ]; then
	source ~/.zsh/zshrc.oh-my-zsh
fi

if [ -f ~/.zshrc.local ]; then
	source ~/.zsh/zshrc.local
fi

if [ -x /usr/bin/direnv ]; then
	eval "$(/usr/bin/direnv hook zsh)"
fi
