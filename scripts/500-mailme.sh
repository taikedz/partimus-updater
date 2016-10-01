mailx -s "Script was run" $(grep -e '^EMAIL=' /etc/partimus.conf |sed -r 's/^EMAIL=//')
