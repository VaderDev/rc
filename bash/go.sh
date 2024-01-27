#!/usr/bin/env bash


# --- Config ---
_vader_go_shortcuts_file="$HOME/bash/go-shortcuts"
_vader_go_shortcuts_indentation="    "

# --- Setup ---
declare -A _vader_go_shortcuts=()
_vader_go_shortcuts_align_key=0
_vader_go_shortcuts_sorted_keys="" # Global cached key sort result, filled on demand

# --- Go completion ---
_vader_go_completion() {
	local FOR_DISPLAY=1

	# TODO P5: Bug: go t<tab>^Cgo t<tab><tab> incorrectly prints a tab and does not prints the possilbe options
	if [ "${__VADER_go_PREV_LINE:-}" != "$COMP_LINE" ] || [ "${__VADER_go_PREV_POINT:-}" != "$COMP_POINT" ]; then
		__VADER_go_PREV_LINE=$COMP_LINE
		__VADER_go_PREV_POINT=$COMP_POINT
		FOR_DISPLAY=
	fi

	local IFS=$'\n'
	COMPREPLY=($(
		for key in "${!_vader_go_shortcuts[@]}"; do
			if [ "${key:0:${#2}}" == "$2" ]; then
				if [ -n "$FOR_DISPLAY" ]; then
					printf "%-*s\n" "$COLUMNS" "$(printf "${_vader_go_shortcuts_indentation}%-${_vader_go_shortcuts_align_key}s" "${key}") - ${_vader_go_shortcuts[$key]}"
				else
					echo "${key}"
				fi
			fi
		done
	))
}

# --- Load shortcuts file ---
_vader_go_reload_shortcuts_file() {
	_vader_go_shortcuts=()

	# Add some defaults
	if [[ "$MSYSTEM" == "MSYS" || "$MSYSTEM" == "MINGW32" || "$MSYSTEM" == "MINGW64" ]]; then
		# Running in MSYS2 or MinGW environment
		_vader_go_shortcuts['desktop']='cd "/c/Users/$(whoami)/Desktop/"'
		_vader_go_shortcuts['tmp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
		_vader_go_shortcuts['temp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
	else
		# Presume linux environment
		_vader_go_shortcuts['desktop']='cd "$HOME/Desktop/"'
		_vader_go_shortcuts['tmp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /tmp)'
		_vader_go_shortcuts['temp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /tmp)'
	fi

	# Load shortcuts file
	i=0
	while IFS= read -r line; do
		((i=i+1))
		if [[ -z "$line" || "$line" == "#"* || "$line" == "//"* ]]; then
			# Skip empty lines and comments
			continue
		fi

		key=${line%%=*}
		if [ -z "$key" ]; then
			echo "Go script error: Missing key in ~/bash/go-shortcuts line $i: \"$line\""
			continue
		fi

		keylen=${#key}
		value=${line:$keylen+1}
		_vader_go_shortcuts[$key]=$value
	done < $_vader_go_shortcuts_file

	# Post process
	_vader_go_shortcuts_align_key=0
	for key in "${!_vader_go_shortcuts[@]}"; do
		if [ ${#key} -gt $_vader_go_shortcuts_align_key ]; then
			_vader_go_shortcuts_align_key=${#key}
		fi
	done
}

_vader_go_reload_shortcuts_file

# --- Go Script ---
go() {
	# Reset completion
	__VADER_go_PREV_LINE=""
	__VADER_go_PREV_POINT=0

	# --- Shortcut editor ---
	# TODO P2: Ability to create 'cd' command from command line (edit file)
	# TODO P3: Ability to create custom command from command line (edit file)
	# TODO P2: Ability to update/delete commands from command line (edit file)

	if [[ $# -gt 0 ]]; then
		case "$1" in
		-a|--add)
			# go --add key command...

			## Check if there is a value after the flag
			#if [[ -n $2 && $2 != -* ]]; then
			#	file="$2"
			#	shift 2  # Consume both the flag and its value
			#else
			#	echo "Error: Argument for $1 is missing or invalid."
			#	return 1
			#fi
			;;
		-c|--cwd)
			# go --cwd key

			## Check if there is a value after the flag
			#if [[ -n $2 && $2 != -* ]]; then
			#	directory="$2"
			#	shift 2  # Consume both the flag and its value
			#	else
			#	echo "Error: Argument for $1 is missing or invalid."
			#	return 1
			#fi
			;;
		-e|--edit)
			# go --edit key command...
			;;
		-u|--update)
			# go --update key
			;;
		-r|--remove)
			# go --remove key
			;;
		-i|--interactive)
			vim $_vader_go_shortcuts_file
			_vader_go_reload_shortcuts_file
			return 0
			;;
		-h|--help)
			echo "Usage: go"
			return 0
			;;
		-*)
			echo "Error: Unknown option '$1'. Use -h or --help for usage information."
			return 1
			;;
		esac
	fi

	# --- Normal execution ---
	if [[ -v "_vader_go_shortcuts[$1]" ]]; then
		# Perfect match
		eval ${_vader_go_shortcuts[$1]}
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

			for key in "${!_vader_go_shortcuts[@]}"; do
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
				eval ${_vader_go_shortcuts[${single_possibile_options}]}
				return
			elif [ $has_possibile_options -ne 0 ]; then
				echo "Multiple shortcut matches '$1'. Possible options are:"
				for key in "${!_vader_go_shortcuts[@]}"; do
					if [ "${key:0:${#1}}" == "$1" ]; then
						printf "%-*s\n" "$COLUMNS" "$(printf "${_vader_go_shortcuts_indentation}%-${_vader_go_shortcuts_align_key}s" "${key}") - ${_vader_go_shortcuts[$key]}"
					fi
				done
				return
			else
				echo "Missing shortcut for '$1'. Possible options are:"
			fi
		fi

		if [ "${_vader_go_shortcuts_sorted_keys}" == "" ]; then
			# First print output run (to reduce bash sourceing time) cache result in global var
			_vader_go_shortcuts_sorted_keys=$(for key in "${!_vader_go_shortcuts[@]}"; do echo $key; done | sort)
		fi
		while read -r key; do
			printf "${_vader_go_shortcuts_indentation}%-${_vader_go_shortcuts_align_key}s - %s\n" "$key" "${_vader_go_shortcuts[$key]}"
		done <<< "$_vader_go_shortcuts_sorted_keys"
	fi
}

complete -F _vader_go_completion go

