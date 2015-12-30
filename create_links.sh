#!/bin/sh

# Creates links in current user's home directory to the files in this repo and
# moves the old files (adds a .bak extension).

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

for script in $(find ${SCRIPTPATH} -type f -iname '\.*'); do
	script=$(basename ${script})
	old_script="${HOME}/${script}"
	if [ -h ${old_script} ]; then
		echo "Deleting old link to ${script}"
		rm ${old_script}
	elif [ -f ${old_script} ]; then
		echo "Moving ${old_script} to ${old_script}.bak"
		if [ -f ${old_script}.bak ]; then
			echo "Error: Backup-file already exists!"
			exit 1
		fi
		mv ${old_script} ${old_script}.bak
	fi
	ln -s ${SCRIPTPATH}/${script} ${HOME}/
done
