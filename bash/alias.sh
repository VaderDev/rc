
# --- alias ---

_tc_bin_path="/e/Utils/TotalCommander/TOTALCMD64.EXE"
_np_bin_path="/f/utility/Notepad++/notepad++.exe"
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



