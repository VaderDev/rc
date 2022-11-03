#!/usr/bin/env bash

# --- alias ---

_tc_bin_path="/d/utility/Total\\ Commander\\ 9.51/TOTALCMD64.EXE"
_np_bin_path="/d/utility/Notepad++/notepad++.exe"
_terminal_bin_path="/e/utility/msys2/mingw64.exe"


alias ..='cd ..'
alias cls='clear'
alias ll='ls -hAlo -F --color=auto --show-control-chars --group-directories-first'
alias ls='ls -hA -F --color=auto --show-control-chars --group-directories-first'
alias rtail="tail --follow=name --retry -n 500"
alias cloc="cloc --force-lang=GLSL,fs,gs,cs,vs"


# g - git
alias g=git
FILE=/usr/share/git/completion/git-completion.bash; [ -f $FILE ] && source $FILE
FILE=/usr/share/bash-completion/completions/git; [ -f $FILE ] && source $FILE
__git_complete g __git_main

# term - Terminal
_term_function() {
	if [[ $# -eq 0 ]]; then
		eval $_terminal_bin_path -where $(pwd) -use-full-path &
	elif [[ $# -eq 1 ]]; then
		eval $_terminal_bin_path -where $1 -use-full-path &
	else
		echo "Too many arguments provided. Usage \"term [path]\""
	fi
}
alias term="_term_function"

# np - Notepad++
_np_function() {
	eval $_np_bin_path $@ &
}
alias np='_np_function'

# tc - Total Commander
_tc_function() {
	if [[ $# -eq 0 ]]; then
		eval $_tc_bin_path -O -T -L="$(pwd)" &
	elif [[ $# -eq 1 ]]; then
		eval $_tc_bin_path -O -T -L="$(realpath $1)" &
	elif [[ $# -eq 2 ]]; then
		eval $_tc_bin_path -O -T -L="$(realpath $1)" -R="$(realpath $2)" &
	else
		echo "Too many arguments provided. Usage \"tc [leftpath] [rightpath]\""
	fi
}
alias tc='_tc_function'

# md
md () {
	mkdir -p -- "$1" &&
	cd -P -- "$1"
}

