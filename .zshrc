# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# {{{ functions

# Update shell files.
function shell_update {
	echo "Updating zshrc.grml..."
	curl -L https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc > ${HOME}/.zsh/zshrc.grml

	echo "Updating antigen.zsh..."
	curl -L git.io/antigen > ${HOME}/.zsh/antigen.zsh

	echo "Updating plugins/fsh..."
	( cd ${HOME}/.zsh/plugins/fsh && git pull )
	echo "Updating plugins/powerlevel10k..."
	( cd ${HOME}/.zsh/plugins/powerlevel10k && git pull )

	echo "Updating Vundle.vim..."
	( cd ${HOME}/.vim/bundle/Vundle.vim && git pull )
}

# Initial setup for shell files.
function shell_setup {
	if [ ! -d ${HOME}/.vim/bundle/Vundle.vim ]; then
		read -p "Vundle.vim not found - install? [yn] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]?$ ]]; then
			mkdir -p ${HOME}/.vim/bundle && \
				git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
		fi
	fi

	if [ ! -d ${HOME}/.zsh/plugins ]; then
		read -p "Clone zsh plugins? [yn] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]?$ ]]; then
			mkdir -p ${HOME}/.zsh/plugins && \
				git clone https://github.com/zdharma/fast-syntax-highlighting ${HOME}/.zsh/plugins/fsh ; \
				git clone https://github.com/romkatv/powerlevel10k.git ${HOME}/.zsh/plugins/powerlevel10k
		fi
	fi

	if [ ! -d ${HOME}/.oh-my-zsh ]; then
		read -p "oh-my-zsh not found - install? [Yn] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]?$ ]]; then
			sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

			\mv ${HOME}/.zshrc.pre-oh-my-zsh ${HOME}/.zshrc
		fi
	fi
}

# Initial setup for zshrcs. Runs in a subshell.
function bootstrap {
	(

	cd $HOME

	mkdir -p .zsh

	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.zlogout 

	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.vimrc
	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.vimrc.grml
	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.gvimrc
	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.p10k.zsh

	cd .zsh

	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.zsh/zshrc.oh-my-zsh
	wget https://github.com/andreas-hofmann/dotfiles/raw/master/.zsh/zshrc.local

	shell_setup
	shell_update

	)
}

# }}}

# {{{ Set the base config.

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
 
# }}}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
