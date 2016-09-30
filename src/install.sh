#!/bin/bash

#%include bashout

if [[ "$UID" -gt 0 ]]; then faile You must be root to run this command
fi

infoe Installing partimus updater ...

apt-get update && apt-get install git anacron -y

cd

git clone https://github.com/taikedz/partimus-updater

cd partimus-updater
cp bin/cronjob /etc/cron.daily/

infoe Completed successfully.
