#!/bin/bash

giturl=https://github.com/taikedz/partimus-updater

#%include bashout askuser

if [[ "$UID" -gt 0 ]]; then faile You must be root to run this command
fi

infoe Installing partimus updater ...

apt-get update && apt-get install git anacron -y

cd /root

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
