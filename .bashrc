# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


case "$TERM" in
xterm*)
	# The following *.exe programs are known to require a Win32 Console
	# for interactive usage, therefore let's launch them through winpty
	# when run inside `mintty`.
	for name in node python ipython php php5 psql mysql
	do
		case "$(type -p "$name".exe 2>/dev/null)" in
		''|/usr/bin/*) continue;;
		esac
		alias $name="winpty $name.exe"
	done
	;;
esac



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



# --- alias ---

_tc_bin_path="/e/Utils/TotalCommander/TOTALCMD64.EXE"
_np_bin_path="/d/Utils/Notepad++/notepad++.exe"
_terminal_bin_path="/e/Utils/MSYS2/msys2_shell.cmd"


alias cls='clear'
alias cmake='cmake -G "Unix Makefiles"'
alias ll='ls -hlao -F --color=auto --show-control-chars --group-directories-first'
alias ls='ls -ha -F --color=auto --show-control-chars --group-directories-first'
alias rtail="tail --follow=name --retry -n 500"

# g - git
alias g=git
source /usr/share/git/completion/git-completion.bash
__git_complete g __git_main

# term - Terminal
_term_function() {
	if [[ $# -eq 0 ]]; then
		$_terminal_bin_path -where $(pwd) -use-full-path &
	elif [[ $# -eq 1 ]]; then
		$_terminal_bin_path -where $1 -use-full-path &
	else
		echo "Too many arguments provided. Usage \"term [path]\""
	fi
}
alias term="_term_function"

# np - Notepad++
_np_function() {
	$_np_bin_path $@ &
}
alias np='_np_function'

# tc - Total Commander
_tc_function() {
	if [[ $# -eq 0 ]]; then
		$_tc_bin_path -O -T -L="$(pwd)" &
	elif [[ $# -eq 1 ]]; then
		$_tc_bin_path -O -T -L="$(realpath $1)" &
	elif [[ $# -eq 2 ]]; then
		$_tc_bin_path -O -T -L="$(realpath $1)" -R="$(realpath $2)" &
	else
		echo "Too many arguments provided. Usage \"tc [leftpath] [rightpath]\""
	fi
}
alias tc='_tc_function'



# --- go script ---

declare -A _go_shortcuts=( 
	["cpp"]="cd /e/dev/cpp/"
	["dev"]="cd /e/dev/"
	["desktop"]="cd /c/Users/$(whoami)/Desktop/"
	["download"]="cd /f/download/"
	["iris"]="cd /e/dev/cpp/iris/"
	["libv"]="cd /e/dev/cpp/libv/"
	["maya"]="cd /d/X-Files/Maya/"
	["mysql"]="cd /d/X-Files/mysql/"
	["project"]="cd /f/project/"
	["todo"]="cd /f/project/todo/"
	["rc"]="cd /f/project/rc/"
	["script"]="cd /f/project/script/"
	["temp"]='cd $(mktemp -d -t __$(date +%Y%m%d_%H%M%S)_XXXXXXXX -p /f/temp)'
	["util"]="cd /e/Utils/"
	["utild"]="cd /d/Utils/"
	["xfiles"]="cd /d/X-Files/"
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


# --- ---
 
