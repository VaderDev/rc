#!/usr/bin/env bash

# --- go script ---

declare -A _go_shortcuts=( 
	["desktop"]='cd /c/Users/$(whoami)/Desktop/'
	["download"]="cd /d/download/"
	["iris"]="cd /e/dev/cpp/iris/"
	["irispro"]="cd /d/project/iris/"
	["libv"]="cd /e/dev/cpp/libv/"
	["maya"]="cd /d/project/iris/maya/scene/"
	["mysql"]="cd /d/project/mysql/"
	["project"]="cd /d/project/"
	["todo"]="cd /d/project/todo/"
	["rc"]="cd /d/project/rc/"
	["script"]="cd /d/project/script/"
	["tmp"]='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
	["temp"]='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
	["util"]="cd /d/utility/"

	["vm"]='ssh vader@192.168.0.200 -p 10220'
)

_go_shortcuts_align_key=10;
_go_shortcuts_indentation='    ';
_go_completion() {
	local FOR_DISPLAY=1
	if [ "${__FOO_PREV_LINE:-}" != "$COMP_LINE" ] || [ "${__FOO_PREV_POINT:-}" != "$COMP_POINT" ]; then
		__FOO_PREV_LINE=$COMP_LINE
		__FOO_PREV_POINT=$COMP_POINT
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
	if [[ -v "_go_shortcuts[$1]" ]]; then
		eval ${_go_shortcuts[$1]}
	else
		if [[ $# -eq 0 ]]; then
			echo "Possible options are:"
		elif [[ $# -gt 1 ]]; then
			echo "Too many arguments provided. Usage \"go <shortcut>\". Possible options are:"
		else
			echo "Missing shortcut for '$1'. Possible options are:"
		fi
		local sorted=$(for key in "${!_go_shortcuts[@]}"; do echo $key; done | sort)
		while read -r key; do
			printf "${_go_shortcuts_indentation}%-${_go_shortcuts_align_key}s - %s\n" "$key" "${_go_shortcuts[$key]}"
		done <<< "$sorted"
	fi
}

complete -F _go_completion go

