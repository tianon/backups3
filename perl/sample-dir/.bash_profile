# ~/.bash_profile: executed by bash(1) for login shells.

umask 002

function echo_titlebar_text
{
	COMMANDf=`history 1 | cut -b 8-`
	COMMANDc=`history 1 | cut -b 8- | cut -b -30`
	
# only add the ellipsis if we actually clipped something
	if [ "$COMMANDf" = "$COMMANDc" ]; then
		COMMAND="$COMMANDf"
	else
		COMMAND="$COMMANDc ..."
	fi
	
	if [ -z "$COMMAND" ]; then
# the command string is empty, so let's just display something
		COMMAND="  ...  "
	fi
	
	MYUSER=$USER
	case $TERM in
		screen|screen.linux)
			MYUSER="$MYUSER &"
			;;
	esac
	
	echo -n "[$HOSTNAME] $COMMAND %% $PWD {$MYUSER}"
}

function setup_ps1
{

local WHITE='\[\033[1;37m\]'
local LIGHTGRAY='\[\033[0;37m\]'
local GREEN='\[\033[0;32m\]'
local LIGHTGREEN='\[\033[1;32m\]'
local LIGHTBLUE='\[\033[1;34m\]'
local RED='\[\033[0;31m\]'

local RESET='\[\033[0m\]' # returns us to the default color ;)

local COLOR=$GREEN # main color for most of the prompt (brackets, time, etc.)
local USER=$LIGHTGREEN # color for user@host
local DIR=$LIGHTBLUE # color for directory
local DOLLAR=$RED # color for $ or #

local EXTRASTUFF=

# add a little more to $PS1 if it applies
case $TERM in
	screen|screen.linux)
		EXTRASTUFF="$EXTRASTUFF$LIGHTGRAY(screen) $RESET"
		;;
esac

local DIREXTRASTUFF=

DIREXTRASTUFF="$DIREXTRASTUFF$WHITE\$(command -v tianon_promptextra.sh &> /dev/null && tianon_promptextra.sh)$RESET"

case $TERM in
	xterm*|rxvt*|linux|cygwin|putty*|screen|screen.linux)
# color is supported?
		PS1="$COLOR\$(date +%H:%M:%S) $COLOR[$USER\u@\h$COLOR $EXTRASTUFF$DIR\w$DIREXTRASTUFF$COLOR]$DOLLAR\\\$$RESET "
		;;
	*)
# don't know about color, assume we don't have it -- TODO add tianon_promptextra to this at some point (although the usefulness of that idea is debatable since I never use worthless terminals that have no color support)
		PS1='$(date +%H:%M:%S) [\u@\h \w]\$ '
		;;
esac

# this can't be conditional because we might not reload .bash_profile (and recreate PS1) when we get into our chroot, so it's good to have here all the time, I guess
PS1='${debian_chroot:+($debian_chroot)}'$PS1

case $TERM in
	xterm*|rxvt*|cygwin|putty*|screen|screen.linux)
		if command -v trap &>/dev/null
		then
			local COMMAND_TO_RUN='echo -en "\033]0;" && echo_titlebar_text && echo -ne "\007"'
			trap - DEBUG
# get even fancier and put the current process name in the titlebar :)
			trap -- "$COMMAND_TO_RUN" DEBUG
#			PROMPT_COMMAND=$COMMAND_TO_RUN
		else
# add directory info to window titlebar!
			PS1=$PS1'\[\033]0;\w # \u@\h\007\]'
		fi
		
		if [ -n "$PROMPT_COMMAND" ]; then
# we have a nasty, ugly PROMPT_COMMAND!  let us KILL it!
			unset PROMPT_COMMAND
		fi
		
		;;
esac

}

# lighten & speedup firefox (apparently -- untested)
export MOZ_DISABLE_PANGO=1

# don't put duplicate lines in the history. See bash(1) for more options
#export HISTCONTROL=ignoredups
# ... and ignore same successive entries
#export HISTCONTROL=ignoreboth
# ... heck, just get rid of all duplicates
export HISTCONTROL=erasedups

shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # check window size after each command and update LINES and COLUMNS

test -r ~/.bashrc && . ~/.bashrc
test -r ~/.profile && . ~/.profile

export PATH=$PATH:$HOME/bin
export PYTHONPATH=$PYTHONPATH:$HOME/bin/python

# call our setup_ps1 function
setup_ps1
# now clean up a little
unset -f setup_ps1

export CLICOLOR=true
if command -v ls &> /dev/null; then
	if ls --color=auto &> /dev/null; then
# --color=auto is supported!  :D
		alias ls="ls --color=auto"
	else
# no color, so we don't even care if there isn't an "ls" alias, just remove anything that might be there
		unalias 'ls' &> /dev/null
	fi
fi

if command -v rlwrap &> /dev/null; then
	alias ocaml="rlwrap -p -f ~/.ocaml_completion ocaml"
fi

if command -v nmap &> /dev/null; then
# since both of these stealth methods require root, we'll call sudo by default
	alias nmap_stealth="sudo nmap -sS"
	alias nmap_superstealth="sudo nmap -sF" # could just as well be -sN or -sX
fi

# set up a few things for vimoutliner, if they aren't already
VIMOUTLINER="vimoutliner-0.3.4"
if [[ -e $HOME/.vim/$VIMOUTLINER/vimoutlinerrc && ! -e $HOME/.vimoutlinerrc ]]; then
	ln -s .vim/$VIMOUTLINER/vimoutlinerrc $HOME/.vimoutlinerrc
fi
if [[ -d $HOME/.vim/$VIMOUTLINER/add-ons && ! -e $HOME/.vimoutliner ]]; then
	ln -s .vim/$VIMOUTLINER/add-ons $HOME/.vimoutliner
fi

# die, emacs/nano/etc, die.
if command -v vim &> /dev/null; then
	export VISUAL=vim
elif command -v vi &> /dev/null; then
	export VISUAL=vi
elif command -v nano &> /dev/null; then
# if we don't have VI or VIM, use Nano :'(
	export VISUAL=nano
fi

if [ -n "$VISUAL" ]; then
	export EDITOR=$VISUAL
fi

if [ -n "$EDITOR" ]; then
	export GIT_EDITOR=$EDITOR
	export SVN_EDITOR=$EDITOR
fi

# login session timeouts are nasty things!  I hate them!
if [ "$TMOUT" != "0" ]; then
	if ! export TMOUT=0 &> /dev/null; then
		echo "Shell timeout could not be disabled: stuck at $TMOUT seconds"
	fi
fi

# a little bit of a hack -- if $USER is empty, fill it with whoami's results -- fixes a few cygwin-related bugs in Windows
if [ -z "$USER" ] && [ -n "$USERNAME" ]; then
	export USER="$USERNAME"
fi
if [ -z "$USER" ] && command -v whoami &> /dev/null; then
	export USER=`whoami 2>/dev/null`
fi
if [ -z "$USER" ]; then
	export USER="unknown_user"
fi

# mac os sucks
if command -v hostname &> /dev/null; then
	export HOSTNAME=$(hostname 2>/dev/null)
	export HOSTNAME=${HOSTNAME%%.*}
	
## hostname -s doesn't always do what we expect it to
#	if hostname -s &> /dev/null; then
#		export HOSTNAME=`hostname -s`
#	else
#		export HOSTNAME=`hostname`
#	fi
fi

WELCOMEMSG="Welcome to $HOSTNAME, $USER"

FIGLET='figlet'

if command -v tput &> /dev/null; then
	FIGLET="$FIGLET -w `tput cols`"
fi

if command -v figlet &> /dev/null; then
	$FIGLET $WELCOMEMSG
else
	echo ''
	echo '***' $WELCOMEMSG '***'
fi
echo ''

if [ "$USER" == "root" ]; then
# I AM ROOT
	ROOTMSG='yippee-ki-yay!'
	echo ''
	if command -v figlet &> /dev/null; then
		echo ''
		$FIGLET $ROOTMSG
	else
		echo '***' $ROOTMSG '***'
	fi
	echo ''
	
# if we are indeed root, give us a fortune
	if command -v fortune &> /dev/null; then
		echo ''
		fortune
		echo ''
	fi
fi
