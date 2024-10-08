#!/usr/bin/env bash


# --- Config ---
_vader_v_shortcuts_file="$HOME/bash/v-shortcuts"
_vader_v_shortcuts_indentation="    "

# --- Setup ---
declare -A _vader_v_shortcuts=()
_vader_v_shortcuts_align_key=0
_vader_v_shortcuts_sorted_keys="" # Global cached key sort result, filled on demand

# --- V completion ---
_vader_v_completion() {
	local FOR_DISPLAY=1

	# TODO P4: Bug: v ech message<tab><tab> incorrectly searches for "message" instead of "ech" (prefix of echo) as key
	# TODO P5: Bug: v t<tab>^Cv t<tab><tab> incorrectly prints a tab and does not prints the possilbe options
	if [ "${__VADER_v_PREV_LINE:-}" != "$COMP_LINE" ] || [ "${__VADER_v_PREV_POINT:-}" != "$COMP_POINT" ]; then
		__VADER_v_PREV_LINE="$COMP_LINE"
		__VADER_v_PREV_POINT="$COMP_POINT"
		FOR_DISPLAY=
	fi

	local IFS=$'\n'
	COMPREPLY=($(
		for key in "${!_vader_v_shortcuts[@]}"; do
			if [ "${key:0:${#2}}" == "$2" ]; then
				if [ -n "$FOR_DISPLAY" ]; then
					printf "%-*s\n" "$COLUMNS" "$(printf "${_vader_v_shortcuts_indentation}%-${_vader_v_shortcuts_align_key}s" "${key}") - ${_vader_v_shortcuts[$key]}"
				else
					echo "${key}"
				fi
			fi
		done
	))
}

# --- Load shortcuts file ---
if [ ! -e "$_vader_v_shortcuts_file" ]; then
    touch "$_vader_v_shortcuts_file"
fi

_vader_v_reload_shortcuts_file() {
	_vader_v_shortcuts=()

	# Add some defaults
	if [[ "$MSYSTEM" == "MSYS" || "$MSYSTEM" == "MINGW32" || "$MSYSTEM" == "MINGW64" ]]; then
		# Running in MSYS2 or MinGW environment
		_vader_v_shortcuts['desktop']='cd "/c/Users/$(whoami)/Desktop/"'
		_vader_v_shortcuts['tmp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
		_vader_v_shortcuts['temp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /d/temp)'
	else
		# Presume linux environment
		_vader_v_shortcuts['desktop']='cd "$HOME/Desktop/"'
		_vader_v_shortcuts['tmp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /tmp)'
		_vader_v_shortcuts['temp']='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /tmp)'
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
			echo "V script error: Missing key in ~/bash/v-shortcuts line $i: \"$line\"."
			continue
		fi

		keylen=${#key}
		value=${line:$keylen+1}
		_vader_v_shortcuts[$key]=$value
	done < "$_vader_v_shortcuts_file"

	# Post process
	_vader_v_shortcuts_align_key=0
	_vader_v_shortcuts_sorted_keys=""
	for key in "${!_vader_v_shortcuts[@]}"; do
		if [ ${#key} -gt $_vader_v_shortcuts_align_key ]; then
			_vader_v_shortcuts_align_key=${#key}
		fi
	done
}

_vader_v_reload_shortcuts_file

# --- V Script ---
v() {
	# Reset completion
	__VADER_v_PREV_LINE=""
	__VADER_v_PREV_POINT=0

	# --- Shortcut editor ---
	if [[ $# -gt 0 ]]; then
		case "$1" in
		-a|--add) # v --add <key> [<command...>]
			key="$2"
			if [[ -z "$key" ]]; then
				echo "Error: Missing key for $1."
				return 1
			fi
			if [[ "$key" == -* ]]; then
				echo "Error: Key \"$key\" is invalid for $1. Keys must not start with \"-\"."
				return 1
			fi

			matching_rows=$(grep -c "^${key}=" "$_vader_v_shortcuts_file")
			if [[ $matching_rows -ne 0 ]]; then
				echo "Error: Key \"$key\" already exists."
				return 2
			fi

			shift 2 # consume flag and key
			if [[ $# -eq 0 ]]; then
				echo "$key=cd \"`pwd`\"" >> "$_vader_v_shortcuts_file"
				echo "Added new shortcut \"$key\" to the current directory: cd \"`pwd`\""
			else
				echo "$key=$*" >> "$_vader_v_shortcuts_file"
				echo "Added new shortcut \"$key\": $*"
			fi

			_vader_v_reload_shortcuts_file
			return 0
			;;
		-u|--update) # v --update <key> [<command...>]
			key="$2"
			if [[ -z "$key" ]]; then
				echo "Error: Missing key for $1."
				return 1
			fi
			if [[ "$key" == -* ]]; then
				echo "Error: Key \"$key\" is invalid for $1. Keys must not start with \"-\"."
				return 1
			fi

			matching_rows=$(grep -c "^${key}=" "$_vader_v_shortcuts_file")
			if [[ $matching_rows -eq 0 ]]; then
				echo "Error: Key \"$key\" is not found."
				return 2
			fi

			shift 2 # consume flag and key
			if [[ $# -eq 0 ]]; then
				command="cd \"`pwd`\""
				escaped_command=$(printf '%s' "$command" | sed -e 's/[\/&]/\\&/g')
				sed -i "s/^${key}=.*/${key}=$escaped_command/g" "$_vader_v_shortcuts_file"
				echo "Updated shortcut \"$key\" to the current directory: cd \"`pwd`\""
			else
				command="$*"
				escaped_command=$(printf '%s' "$command" | sed -e 's/[\/&]/\\&/g')
				sed -i "s/^${key}=.*/${key}=$escaped_command/g" "$_vader_v_shortcuts_file"
				echo "Updated shortcut \"$key\": $*"
			fi

			_vader_v_reload_shortcuts_file
			return 0
			;;
		-s|--save) # v --save <key> [<command...>]
			key="$2"
			if [[ -z "$key" ]]; then
				echo "Error: Missing key for $1."
				return 1
			fi
			if [[ "$key" == -* ]]; then
				echo "Error: Key \"$key\" is invalid for $1. Keys must not start with \"-\"."
				return 1
			fi

			matching_rows=$(grep -c "^${key}=" "$_vader_v_shortcuts_file")
			shift 2 # consume flag and key
			if [[ $matching_rows -eq 0 ]]; then
				# Create mode
				if [[ $# -eq 0 ]]; then
					echo "$key=cd \"`pwd`\"" >> "$_vader_v_shortcuts_file"
					echo "Added new shortcut \"$key\" to the current directory: cd \"`pwd`\""
				else
					echo "$key=$*" >> "$_vader_v_shortcuts_file"
					echo "Added new shortcut \"$key\": $*"
				fi
			else
				# Update mode
				if [[ $# -eq 0 ]]; then
					command="cd \"`pwd`\""
					escaped_command=$(printf '%s' "$command" | sed -e 's/[\/&]/\\&/g')
					sed -i "s/^${key}=.*/${key}=$escaped_command/g" "$_vader_v_shortcuts_file"
					echo "Updated shortcut \"$key\" to the current directory: cd \"`pwd`\""
				else
					command="$*"
					escaped_command=$(printf '%s' "$command" | sed -e 's/[\/&]/\\&/g')
					sed -i "s/^${key}=.*/${key}=$escaped_command/g" "$_vader_v_shortcuts_file"
					echo "Updated shortcut \"$key\": $*"
				fi
			fi

			_vader_v_reload_shortcuts_file
			return 0
			;;
		-r|--remove|-d|--delete) # v --remove <key>
			key="$2"
			if [[ -z "$key" ]]; then
				echo "Error: Missing key for $1."
				return 1
			fi
			if [[ "$key" == -* ]]; then
				echo "Error: Key \"$key\" is invalid for $1. Keys must not start with \"-\"."
				return 1
			fi
			if [[ $# -gt 2 ]]; then
				echo "Error: Too many arguments for $1. Arguments \"$*\" are unused."
				return 1
			fi

			matching_rows=$(grep -c "^${key}=" "$_vader_v_shortcuts_file")
			if [[ $matching_rows -eq 0 ]]; then
				echo "Error: Key \"$key\" is not found."
				return 2
			fi

			sed -i "/^${key}=/d" "$_vader_v_shortcuts_file"
			echo "Removed shortcut \"$key\"."
			_vader_v_reload_shortcuts_file
			return 0
			;;
		-e|--edit) # v --edit
			if [[ $# -gt 2 ]]; then
				echo "Error: Too many arguments for $1. Arguments \"$*\" are unused."
				return 1
			fi

			vim "$_vader_v_shortcuts_file"
			_vader_v_reload_shortcuts_file
			return 0
			;;
		-h|--help)
			echo "Usage: v [KEY|SUBCOMMAND]"
			echo "  v <key>                          Execute a shortcut"
			echo ""
			echo "SUBCOMMAND:"
			echo "  -a, --add <key> [<command...>]    Create a new shortcut"
			echo "  -s, --save <key> [<command...>]   Create or update a shortcut"
			echo "  -u, --update <key> [<command...>] Update the command of an existing shortcut"
			echo "  -r, --remove <key>                Remove an existing shortcut"
			echo "  -e, --edit                        Opens an interactive editor to edit the shortcut"
			echo "  -h, --help"
			return 0
			;;
		-*)
			echo "Error: Unknown option '$1'. Use -h or --help for usage information."
			return 1
			;;
		esac
	fi

	# --- Normal execution ---
	arg_count=$#
	arg_key="$1"
	shift 1

	if [[ -v "_vader_v_shortcuts[$arg_key]" ]]; then
		# Perfect match
		eval ${_vader_v_shortcuts[$arg_key]} $@
	else
		if [[ $arg_count -eq 0 ]]; then
			# No argument
			echo "Possible options are:"
		else
			# One or more argument
			local single_possibile_options=""
			local has_possibile_options=0

			for key in "${!_vader_v_shortcuts[@]}"; do
				if [ "${key:0:${#arg_key}}" == "$arg_key" ]; then
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
				eval ${_vader_v_shortcuts[${single_possibile_options}]} $@
				return
			elif [ $has_possibile_options -ne 0 ]; then
				echo "Multiple shortcut matches '$arg_key'. Possible options are:"
				for key in "${!_vader_v_shortcuts[@]}"; do
					if [ "${key:0:${#arg_key}}" == "$arg_key" ]; then
						printf "%-*s\n" "$COLUMNS" "$(printf "${_vader_v_shortcuts_indentation}%-${_vader_v_shortcuts_align_key}s" "${key}") - ${_vader_v_shortcuts[$key]}"
					fi
				done
				return
			else
				echo "Missing shortcut for '$arg_key'. Possible options are:"
			fi
		fi

		if [ "${_vader_v_shortcuts_sorted_keys}" == "" ]; then
			# First print output run (to reduce bash sourceing time) cache result in global var
			_vader_v_shortcuts_sorted_keys=$(for key in "${!_vader_v_shortcuts[@]}"; do echo $key; done | sort)
		fi
		while read -r key; do
			printf "${_vader_v_shortcuts_indentation}%-${_vader_v_shortcuts_align_key}s - %s\n" "$key" "${_vader_v_shortcuts[$key]}"
		done <<< "$_vader_v_shortcuts_sorted_keys"
	fi
}

complete -F _vader_v_completion v

