#!/usr/bin/env bash

set -euo pipefail

giturl=https://github.com/taikedz/partimus-updater

#%include isroot.sh
#%include out.sh
#%include askuser.sh

#%include configuration.sh

install_system_dependencies() {
    apt-get update && apt-get install git anacron mailutils -y
}

deploy_files() {
    cp bin/cronjob /etc/cron.daily/
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
