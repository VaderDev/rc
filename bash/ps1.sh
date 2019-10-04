#!/usr/bin/env bash

# --- PS1 ---

if [[ $EUID -eq 0 ]]; then
	# If root: root@host pwd>
	PS1_HOST="\[\e[1;31m\]\h\[\e[m\]"
	PS1_USER="\[\e[1;31m\]\u\[\e[m\]"
	PS1_DIRECTORY="\[\e[33m\]\w\[\e[m\]"

	PS1_TITLE="\[\e]0;\u@\h \w\a\]"
	PS1="${PS1_TITLE}${PS1_USER}\[\e[33m\]@\[\e[m\]${PS1_HOST} ${PS1_DIRECTORY}> "

elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	# If SSH: user@host pwd>
	PS1_HOST="\[\e[33m\]\h\[\e[m\]"
	PS1_USER="\[\e[36m\]\u\[\e[m\]"
	PS1_DIRECTORY="\[\e[32m\]\w\[\e[m\]"

	PS1_TITLE="\[\e]0;\u@\h \w\a\]"
	PS1="${PS1_TITLE}${PS1_USER}@${PS1_HOST} ${PS1_DIRECTORY}> "
else
	# Otherwise: pwd>
	PS1_DIRECTORY="\[\e[32m\]\w\[\e[m\]"

	PS1_TITLE="\[\e]0;\w\a\]"
	PS1="${PS1_TITLE}${PS1_DIRECTORY}> "
fi

