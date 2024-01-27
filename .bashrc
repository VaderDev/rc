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

# ---

source ~/bash/alias.sh
source ~/bash/ps1.sh
source ~/bash/go.sh
source ~/bash/env.sh

