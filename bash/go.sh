#!/usr/bin/env bash

declare -A _go_shortcuts=(
	['desktop']='cd /c/Users/$(whoami)/Desktop/'
	['download']='cd /d/download/'
	['tmp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
	['temp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
	['util']='cd /d/utility/'

	['piris']='cd /d/project/iris/'
	['maya']='cd /d/project/iris/maya/scene/'
	['mysql']='cd /d/project/mysql/'
	['project']='cd /d/project/'
	['todo']='cd /d/project/todo/'
	['rc']='cd /d/project/rc/'
	['script']='cd /d/project/script/'
	['web']='cd /d/project/web/corruptedai.com/'

	['cpp']='cd /d/dev/cpp/'
	['libv']='cd /d/dev/cpp/libv/'
	['iris']='cd /d/dev/cpp/iris/'
	['fork']='cd /d/dev/cpp/forks/'
	['wish']='cd /d/dev/cpp/wish/'

	['vm']='ssh -t vader@192.168.0.200 -p 10022 screen -x -RR'

	['ca-dev']='ssh -t vader@dev.corruptedai.com -p 16022 screen -x -RR'
)

declare -A _go_shortcuts_rs=(
	["tmp"]='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /tmp)'
	["temp"]='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /tmp)'

	["rs0"]='ssh vader@rs0.corruptedai.com -p 10122'
)



# --- go script ---

# TODO P1: Store go shortcuts in a file and auto load the systems go file
# TODO P2: Ability to create 'cd' command from command line (edit file)
# TODO P3: Ability to create custom command from command line (edit file)
# TODO P2: Ability to update/delete commands from command line (edit file)

_go_shortcuts_align_key=10;
_go_shortcuts_indentation="    ";
_go_shortcuts_sorted_keys=""; # Global cached key sort result, filled on demand
_go_completion() {
	local FOR_DISPLAY=1

	# TODO P5: Bug: go t<tab>^Cgo t<tab><tab> incorrectly prints a tab and does not prints the possilbe options
	if [ "${__VADER_GO_PREV_LINE:-}" != "$COMP_LINE" ] || [ "${__VADER_GO_PREV_POINT:-}" != "$COMP_POINT" ]; then
		__VADER_GO_PREV_LINE=$COMP_LINE
		__VADER_GO_PREV_POINT=$COMP_POINT
		FOR_DISPLAY=
	fi

	local IFS=$'\n'
	COMPREPLY=($(
		for key in "${!_go_shortcuts[@]}"; do
			if [ "${key:0:${#2}}" == "$2" ]; then
				if [ -n "$FOR_DISPLAY" ]; then
					printf "%-*s\n" "$COLUMNS" "$(printf "${_go_shortcuts_indentation}%-${_go_shortcuts_align_key}s" "${key}") - ${_go_shortcuts[$key]}"
				else
					echo "${key}"
				fi
			fi
		done
	))
}

go() {
	# Reset completion
	__VADER_GO_PREV_LINE=""
	__VADER_GO_PREV_POINT=0

	if [[ -v "_go_shortcuts[$1]" ]]; then
		# Perfect match
		eval ${_go_shortcuts[$1]}
	else
		if [[ $# -eq 0 ]]; then
			# No argument
			echo "Possible options are:"
		elif [[ $# -gt 1 ]]; then
			# More than one argument
			echo "Too many arguments provided. Usage \"go <shortcut>\". Possible options are:"
		else
			# One argument
			local single_possibile_options=""
			local has_possibile_options=0

			for key in "${!_go_shortcuts[@]}"; do
				if [ "${key:0:${#1}}" == "$1" ]; then
					has_possibile_options=1
					if [ "${single_possibile_options}" == "" ]; then
						single_possibile_options="${key}"
					else
						single_possibile_options=""
						break
					fi
				fi
			done

			if [ "${single_possibile_options}" != "" ]; then
				eval ${_go_shortcuts[${single_possibile_options}]}
				return
			elif [ $has_possibile_options -ne 0 ]; then
				echo "Multiple shortcut matches '$1'. Possible options are:"
				for key in "${!_go_shortcuts[@]}"; do
					if [ "${key:0:${#1}}" == "$1" ]; then
						printf "%-*s\n" "$COLUMNS" "$(printf "${_go_shortcuts_indentation}%-${_go_shortcuts_align_key}s" "${key}") - ${_go_shortcuts[$key]}"
					fi
				done
				return
			else
				echo "Missing shortcut for '$1'. Possible options are:"
			fi
		fi

		if [ "${_go_shortcuts_sorted_keys}" == "" ]; then
			# First print output run (to reduce bash sourceing time) cache result in global var
			_go_shortcuts_sorted_keys=$(for key in "${!_go_shortcuts[@]}"; do echo $key; done | sort)
		fi
		while read -r key; do
			printf "${_go_shortcuts_indentation}%-${_go_shortcuts_align_key}s - %s\n" "$key" "${_go_shortcuts[$key]}"
		done <<< "$_go_shortcuts_sorted_keys"
	fi
}

complete -F _go_completion go

