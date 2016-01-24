#!/bin/bash

# Creates links in current user's home directory to the files in this repo and
# moves the old files (adds a .bak extension).

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

#set -x

if [ ! -d ${HOME}/.oh-my-zsh ]; then
	read -p "oh-my-zsh not found - install? [Yn] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]?$ ]]; then
		sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	fi
fi

function link_script {
	script=$(basename $1)

	old_script="${HOME}/${script}"
	if [ -h ${old_script} ]; then
		echo "Deleting old link to ${script}"
		rm ${old_script}
	elif [ -f ${old_script} ]; then
		echo "Moving ${old_script} to ${old_script}.bak"
		if [ -e ${old_script}.bak ]; then
			echo "Error: Backup-file already exists!"
			exit 1
		fi
		mv ${old_script} ${old_script}.bak
	fi
	ln -s ${SCRIPTPATH}/${script} ${HOME}/
}

function link_dir {
	dir=$1
	subdir=$2

	old_dir="${HOME}/${subdir}/${dir}"
	if [ -h ${old_dir} ]; then
		echo "Deleting old link to ${dir}"
		rm ${old_dir}
	elif [ -d ${old_dir} ]; then
		echo "Moving ${old_dir} to ${old_dir}.bak"
		if [ -e ${old_dir}.bak ]; then
			echo "Error: Backup-dir already exists!"
			exit 1
		fi
		mv ${old_dir} ${old_dir}.bak
	fi
	ln -s ${SCRIPTPATH}/${subdir}/${dir} ${HOME}/${subdir}/${dir}
}

for script in $(find ${SCRIPTPATH} -type f -iname '\.*'); do
	link_script ${script}
done

for dir in $(find ${SCRIPTPATH} -type d -iname '\.*'); do
	directory=$(basename ${dir})

	if [ ${directory} = ".git" ]; then
		# Don't copy git info, skip to next directory
		continue
	elif [ ${directory} = ".config" ]; then
		# Don't link complete config dir, it probably holds a lot of previous entries
		for subdir in $(find ${dir} -type d); do
			subdirectory=$(basename ${subdir})
			link_dir ${subdirectory} ${directory}
		done
	else
		link_dir ${directory}
	fi
done
