#!/bin/bash

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

if [[ "$UID" -gt 0 ]]; then faile You must be root to run this command
fi

infoe Installing partimus updater ...

apt-get update && apt-get install git anacron -y

cd

git clone https://github.com/taikedz/partimus-updater

cd partimus-updater
cp bin/cronjob /etc/cron.daily/

infoe Completed successfully.
