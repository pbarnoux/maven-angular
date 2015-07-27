#!/bin/sh -e

if [ ! -z "$http_proxy" ]; then
	if [ -z "$https_proxy" ]; then
		export https_proxy="$http_proxy"
	fi
	npm config set proxy "$http_proxy"
	npm config set https-proxy "$https_proxy"
fi

# Yo will run as a undefined user, but not root
# Make sure he has access to anything
mkdir -p /root/.cache/bower
mkdir -p /root/.local/share/bower
chmod -R 777 /root/.cache
chmod -R 777 /root/.local
chmod -R 777 /root/.npm
ls -ail /root > /dev/null

exec "$@"

