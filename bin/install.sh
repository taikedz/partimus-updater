#!/usr/bin/env bash

set -euo pipefail

giturl=https://github.com/taikedz/partimus-updater

##bash-libs: tty.sh @ 69724119 (2.0)

tty:is_ssh() {
    [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CLIENT" ]] || [[ "$SSH_CONNECTION" ]]
}

tty:is_pipe() {
    [[ ! -t 1 ]]
}

##bash-libs: colours.sh @ 69724119 (2.0)

### Colours for terminal Usage:bbuild
# A series of shorthand colour flags for use in outputs, and functions to set your own flags.
#
# Not all terminals support all colours or modifiers.
#
# Example:
# 	
# 	echo "${CRED}Some red text ${CBBLU} some blue text. $CDEF Some text in the terminal's default colour")
#
# Preconfigured colours available:
#
# CRED, CBRED, HLRED -- red, bright red, highlight red
# CGRN, CBGRN, HLGRN -- green, bright green, highlight green
# CYEL, CBYEL, HLYEL -- yellow, bright yellow, highlight yellow
# CBLU, CBBLU, HLBLU -- blue, bright blue, highlight blue
# CPUR, CBPUR, HLPUR -- purple, bright purple, highlight purple
# CTEA, CBTEA, HLTEA -- teal, bright teal, highlight teal
# CBLA, CBBLA, HLBLA -- black, bright red, highlight red
# CWHI, CBWHI, HLWHI -- white, bright red, highlight red
#
# Modifiers available:
#
# CBON - activate bright
# CDON - activate dim
# ULON - activate underline
# RVON - activate reverse (switch foreground and background)
# SKON - activate strikethrough
# 
# Resets available:
#
# CNORM -- turn off bright or dim, without affecting other modifiers
# ULOFF -- turn off highlighting
# RVOFF -- turn off inverse
# SKOFF -- turn off strikethrough
# HLOFF -- turn off highlight
#
# CDEF -- turn off all colours and modifiers(switches to the terminal default)
#
# Note that highlight and underline must be applied or re-applied after specifying a colour.
#
# If the session is detected as being in a pipe, colours will be turned off.
#   You can override this by calling `colours:check --color=always` at the start of your script
#
###/doc

### colours:check ARGS ... Usage:bbuild
#
# Check the args to see if there's a `--color=always` or `--color=never`
#   and reload the colours appropriately
#
#   main() {
#       colours:check "$@"
#
#       echo "${CGRN}Green only in tty or if --colours=always !${CDEF}"
#   }
#
#   main "$@"
#
###/doc
colours:check() {
    if [[ "$*" =~ --color=always ]]; then
        COLOURS_ON=true
    elif [[ "$*" =~ --color=never ]]; then
        COLOURS_ON=false
    fi

    colours:define
    return 0
}

### colours:set CODE Usage:bbuild
# Set an explicit colour code - e.g.
#
#   echo "$(colours:set "33;2")Dim yellow text${CDEF}"
#
# See SGR Colours definitions
#   <https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters>
###/doc
colours:set() {
    # We use `echo -e` here rather than directly embedding a binary character
    if [[ "$COLOURS_ON" = false ]]; then
        return 0
    else
        echo -e "\033[${1}m"
    fi
}

colours:define() {

    # Shorthand colours

    export CBLA="$(colours:set "30")"
    export CRED="$(colours:set "31")"
    export CGRN="$(colours:set "32")"
    export CYEL="$(colours:set "33")"
    export CBLU="$(colours:set "34")"
    export CPUR="$(colours:set "35")"
    export CTEA="$(colours:set "36")"
    export CWHI="$(colours:set "37")"

    export CBBLA="$(colours:set "1;30")"
    export CBRED="$(colours:set "1;31")"
    export CBGRN="$(colours:set "1;32")"
    export CBYEL="$(colours:set "1;33")"
    export CBBLU="$(colours:set "1;34")"
    export CBPUR="$(colours:set "1;35")"
    export CBTEA="$(colours:set "1;36")"
    export CBWHI="$(colours:set "1;37")"

    export HLBLA="$(colours:set "40")"
    export HLRED="$(colours:set "41")"
    export HLGRN="$(colours:set "42")"
    export HLYEL="$(colours:set "43")"
    export HLBLU="$(colours:set "44")"
    export HLPUR="$(colours:set "45")"
    export HLTEA="$(colours:set "46")"
    export HLWHI="$(colours:set "47")"

    # Modifiers
    
    export CBON="$(colours:set "1")"
    export CDON="$(colours:set "2")"
    export ULON="$(colours:set "4")"
    export RVON="$(colours:set "7")"
    export SKON="$(colours:set "9")"

    # Resets

    export CBNRM="$(colours:set "22")"
    export HLOFF="$(colours:set "49")"
    export ULOFF="$(colours:set "24")"
    export RVOFF="$(colours:set "27")"
    export SKOFF="$(colours:set "29")"

    export CDEF="$(colours:set "0")"

}

colours:auto() {
    if tty:is_pipe ; then
        COLOURS_ON=false
    else
        COLOURS_ON=true
    fi

    colours:define
    return 0
}

colours:auto

##bash-libs: out.sh @ 69724119 (2.0)

### Console output handlers Usage:bbuild
#
# Write data to console stderr using colouring
#
###/doc

### out:info MESSAGE Usage:bbuild
# print a green informational message to stderr
###/doc
function out:info {
    echo "$CGRN$*$CDEF" 1>&2
}

### out:warn MESSAGE Usage:bbuild
# print a yellow warning message to stderr
###/doc
function out:warn {
    echo "${CBYEL}WARN: $CYEL$*$CDEF" 1>&2
}

### out:defer MESSAGE Usage:bbuild
# Store a message in the output buffer for later use
###/doc
function out:defer {
    OUTPUT_BUFFER_defer[${#OUTPUT_BUFFER_defer[@]}]="$*"
}

# Internal
function out:buffer_initialize {
    OUTPUT_BUFFER_defer=(:)
}
out:buffer_initialize

### out:flush HANDLER ... Usage:bbuild
#
# Pass the output buffer to the command defined by HANDLER
# and empty the buffer
#
# Examples:
#
# 	out:flush echo -e
#
# 	out:flush out:warn
#
# (escaped newlines are added in the buffer, so `-e` option is
#  needed to process the escape sequences)
#
###/doc
function out:flush {
    [[ -n "$*" ]] || out:fail "Did not provide a command for buffered output\n\n${OUTPUT_BUFFER_defer[*]}"

    [[ "${#OUTPUT_BUFFER_defer[@]}" -gt 1 ]] || return 0

    for buffer_line in "${OUTPUT_BUFFER_defer[@]:1}"; do
        "$@" "$buffer_line"
    done

    out:buffer_initialize
}

### out:fail [CODE] MESSAGE Usage:bbuild
# print a red failure message to stderr and exit with CODE
# CODE must be a number
# if no code is specified, error code 127 is used
###/doc
function out:fail {
    local ERCODE=127
    local numpat='^[0-9]+$'

    if [[ "$1" =~ $numpat ]]; then
        ERCODE="$1"; shift || :
    fi

    echo "${CBRED}ERROR FAIL: $CRED$*$CDEF" 1>&2
    exit $ERCODE
}

### out:error MESSAGE Usage:bbuild
# print a red error message to stderr
#
# unlike out:fail, does not cause script exit
###/doc
function out:error {
    echo "${CBRED}ERROR: ${CRED}$*$CDEF" 1>&2
}

##bash-libs: isroot.sh @ 69724119 (2.0)

### isroot Usage:bbuild
# Test for root access
#
# If using cygwin, user is always root.
###/doc

function isroot {
    [[ "$UID" = 0 ]] || isroot:cygwin
}

### isroot:cygwin Usage:bbuild
# Returns whether running under cygwin.
#
# Typically a user under cygwin is root, except when they're not
#
# This utility exists as a reminder to check for cygwin.
###/doc

function isroot:cygwin {
    uname -o | grep -i cygwin -q
}

### isroot:require MESSAGE Usage:bbuild
# Require root. If script is not running as root,
# print message and exit
###/doc
function isroot:require {
    isroot || out:fail "$*"
}

##bash-libs: askuser.sh @ 69724119 (2.0)

### askuser Usage:bbuild
# Present the user with questions on stderr
###/doc

yespat='^(yes|YES|y|Y)$'
numpat='^[0-9]+$'
rangepat='[0-9]+,[0-9]+'
listpat='^[0-9 ]+$'
blankpat='^ *$'

### askuser:confirm Usage:bbuild
# Ask the user to confirm a closed question. Defaults to no
#
# returns 0 on successfully match 'y' or 'yes'
# returns 1 otherwise
###/doc
function askuser:confirm {
    read -p "$* [y/N] > " 1>&2
    if [[ "$REPLY" =~ $yespat ]]; then
        return 0
    else
        return 1
    fi
}

### askuser:ask Usage:bbuild
# Ask the user to provide some text
#
# Echoes out the entered text
###/doc
function askuser:ask {
    read -p "$* : " 1>&2
    echo "$REPLY"
}

### askuser:password Usage:bbuild
# Ask the user to enter a password (does not echo what is typed)
#
# Echoes out the entered text
###/doc
function askuser:password {
    read -s -p "$* : " 1>&2
    echo >&2
    echo "$REPLY"
}

### askuser:choose_multi Usage:bbuild
# Allows the user to choose from multiple choices
#
# askuser:chose_multi MESG CHOICESTRING
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
# * `a`, `b` and `c` on their own lines
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
function askuser:choose_multi {
    local mesg=$1; shift || :
    local choices=$(echo "$*"|sed -r 's/ *, */\n/g')

    out:info "$mesg:" 
    local choicelist="$(echo -e "$choices"|grep -E '^' -n| sed 's/:/: /')"
    echo "$choicelist" 1>&2
    
    local sel=$(askuser:ask "Choice")
    if [[ "$sel" =~ $blankpat ]]; then
        return 1

    elif [[ "$sel" =~ $numpat ]] || [[ "$sel" =~ $rangepat ]]; then
        echo -e "$choices" | sed -n "$sel p"
    
    elif [[ "$sel" =~ $listpat ]]; then
        echo "$choicelist" | grep -E "^${sel// /|}:" | sed -r 's/^[0-9]+: //'

    else
        echo -e "$choices"  |grep -E "$(echo "$sel"|tr " " '|')"
    fi
    return 0
}

### askuser:choose Usage:bbuild
# Ask the user to choose an item
#
# Like askuser:choose_multi, but will loop if the user selects more than one item
#
# If the user provides no entry, returns 1
#
# If the user chooses one item, that item is echoed to stdout
###/doc
function askuser:choose {
    local mesg=$1; shift || :
    while true; do
        local thechoice="$(askuser:choose_multi "$mesg" "$*")"
        local lines=$(echo -n "$thechoice" | grep '$' -c)
        if [[ $lines = 1 ]]; then
            echo "$thechoice"
            return 0
        elif [[ $lines = 0 ]]; then
            return 1
        else
            out:warn "Too many results"
        fi
    done
}

PUP_conf=/etc/partimus/updater.conf
PUP_logfile=/var/log/partimus/updater.log
PUP_gitdir=/root/partimus-updater

install_system_dependencies() {
    apt-get update && apt-get install git anacron mailutils -y
}

deploy_files() {
    cp bin/partimus-updater-cronjob /etc/cron.daily/
    mkdir -p "$(dirname "$PUP_conf")"
    cp partimus.conf "$PUP_conf"
}

configure_install() {
    emails=$(askuser:ask "Email(s) to send notifications to")
    sed "s/^email=.*/email=$emails/" -i "$PUP_conf"

    machinename=$(askuser:ask "Name of this machine (for the emails)")
    sed -r "s/^machine=.*/machine=$machinename/" -i "$PUP_conf"
}

main() {
    isroot:require "You must be root to install the updater"

    cd "$(dirname "$PUP_gitdir")"

    out:info "Installing partimus updater ..."

    if [[ ! -d "$PUP_gitdir" ]] && [[ ! -L "$PUP_gitdir" ]]; then
        git clone "$giturl" partimus-updater
    fi

    cd partimus-updater

    install_system_dependencies
    deploy_files
    configure_install

    out:info "Completed successfully."
}

main "$@"
