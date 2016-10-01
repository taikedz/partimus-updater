#!/bin/bash

giturl=https://github.com/taikedz/partimus-updater

#!/bin/bash

#!/bin/bash

export CDEF="[0m"
export CRED="[31m"
export CGRN="[32m"
export CYEL="[33m"
export CBLU="[34m"
export CBRED="[1;31m"
export CBGRN="[1;32m"
export CBYEL="[1;33m"
export CBBLU="[1;34m"

MODE_DEBUG=no

### debuge MESSAGE Usage:bbuild
# print a blue debug message to stderr
# only prints if MODE_DEBUG is set to "yes"
###/doc
function debuge {
	if [[ "$MODE_DEBUG" = yes ]]; then
		echo -e "${CBBLU}DEBUG:$CBLU$*$CDEF" 1>&2
	fi
}

### infoe MESSAGE Usage:bbuild
# print a green informational message to stderr
###/doc
function infoe {
	echo -e "$CGRN$*$CDEF" 1>&2
}

### warne MESSAGE Usage:bbuild
# print a yellow warning message to stderr
###/doc
function warne {
	echo -e "${CBYEL}WARN:$CYEL $*$CDEF" 1>&2
}

### faile MESSAGE CODE Usage:bbuild
# print a red failure message to stderr and exit with CODE
# CODE must be a number
# if no code is specified, error code 127 is used
###/doc
function faile {
	local MSG=
	local ARG=
	local ERCODE=127
	local numpat='^[0-9]+$'
	while [[ -n "$*" ]]; do
		ARG=$1 ; shift
		if [[ -z "$*" ]] && [[ "$ARG" =~ $numpat ]]; then
			ERCODE=$ARG
		else
			MSG="$MSG $ARG"
		fi
	done
	echo "${CBRED}ERROR FAIL:$CRED$MSG$CDEF" 1>&2
	exit "$ERCODE"
}

function dumpe {
	echo -n "[1;35m$*" 1>&2
	echo -n "[0;35m" 1>&2
	cat - 1>&2
	echo -n "[0m" 1>&2
}

if [[ "$*" =~ --debug ]]; then
	MODE_DEBUG=yes
fi
#!/bin/bash

### AskUser Usage:bbuild
# Present the user with questions on stdout
###/doc


yespat='^(yes|YES|y|Y)$'
numpat='^[0-9]+$'
rangepat='[0-9]+,[0-9]+'
blankpat='^ *$'

### uconfirm Usage:bbuild
# Ask the user to confirm a closed question. Defaults to no
#
# returns 0 on successfully match 'y' or 'yes'
# returns 1 otherwise
###/doc
function uconfirm {
	read -p "$* [y/N] > " 1>&2
	if [[ "$REPLY" =~ $yespat ]]; then
		return 0
	else
		return 1
	fi
}

### uask Usage:bbuild
# Ask the user to provide some text
#
# returns the entered text
###
function uask {
	read -p "$* : " 1>&2
	echo $REPLY
}

### uchoose_multi Usage:bbuild
# Allows the user to choose from multiple choices
#
# uchose_multi MESG CHOICESTRING
#
#
# MESG is a single string token that will be displayed as prompt
#
# CHOICESTRING is a comma-separated, or newline separated, or "\\n"-separated token string
#
# Equivalent strings include:
#
# * `"a\\nb\\nc"` - quoted and explicit newline escapes
# * `"a,b,c"` - quoted and separated with commas
# * `a , b , c` - not quoted, separated by commas
# * (and `a`, `b` and `c` on their own lines)
#
# User input:
#
# User can choose by selecting
#
# * a single item by number
# * a range of numbers (4,7 for range 4 to 7)
# * or a string that matches the pattern
#
# All option lines that match will be returned, one per line
#
# If the user selects nothing, then function returns 1 and an empty stdout
###/doc
function uchoose_multi {
	local mesg=$1; shift
	local choices=$(echo "$*"|sed -r 's/ *, */\n/g')
	debuge "CHOICES: $choices"

	infoe "$mesg:" 
	echo -e "$choices"|egrep '^' -n| sed 's/:/: /' 1>&2
	
	local sel=$(uask "Choice")
	if [[ "$sel" =~ $blankpat ]]; then
		return 1
	elif [[ "$sel" =~ $numpat ]] || [[ "$sel" =~ $rangepat ]]; then
		debuge "Number choice [$sel]"
		echo -e "$choices" | sed -n "$sel p"
	else
		debuge "Pattern choice [$sel]"
		echo -e "$choices"  |egrep "$(echo "$sel"|tr " " '|')"
	fi
	return 0
}

### uchoose Usage:bbuild
# Ask the user to choose an item
#
# Like uchoose_multi, but will loop if the user selects more than one item
#
# If the provides no entry, returns 0
#
# If the user chooses one item, that item is echoed to stdout
###/doc
function uchoose {
	local mesg=$1; shift
	while true; do
		local thechoice="$(uchoose_multi "$mesg" "$*")"
		local lines=$(echo "$thechoice" | wc -l)
		if [[ $lines = 1 ]]; then
			echo "$thechoice"
			return 0
		else
			warne "Too many results"
		fi
	done
}


if [[ "$UID" -gt 0 ]]; then faile You must be root to run this command
fi

infoe Installing partimus updater ...

apt-get update && apt-get install git anacron -y

cd

if [[ ! -d partimus-updater ]]; then
	git clone "$giturl" partimus-updater
fi

cd partimus-updater
cp bin/cronjob /etc/cron.daily/

cp partimus.conf /etc/

emails=$(uask "Email(s) to send notifications to")
sed "s/EMAIL=/EMAIL=$emails/" -i /etc/partimus.conf

machinename=$(uask "Name of this machine (for the emails)")
sed "s/MACHINE=/MACHINE=$machinename/" -i /etc/partimus.conf

infoe Completed successfully.
