printf "[%12s] starting\n" "setenv.sh" >> /var/log/startup_sequence
printf "[%12s] is http_proxy environment variable set? " "setenv.sh" >> /var/log/startup_sequence
if [ ! -z "$http_proxy" ]; then
	printf " yes ['%s']\n" "$http_proxy" >> /var/log/startup_sequence
	printf "[%12s] is https_proxy environment variable set? " "setenv.sh" >> /var/log/startup_sequence

	if [ -z "$https_proxy" ]; then
		printf "no, using $http_proxy\n" >> /var/log/startup_sequence
		export https_proxy="$http_proxy"
	else
		printf "yes ['%s']\n" "$https_proxy" >> /var/log/startup_sequence
	fi
	printf "[%12s] configuring npm proxy and https-proxy\n" "setenv.sh" >> /var/log/startup_sequence
	/usr/bin/npm config set proxy "$http_proxy"
	/usr/bin/npm config set https-proxy "$https_proxy"
else
	printf "no\n" >> /var/log/startup_sequence
fi
# Export functions used by other scripts
source /root/bin/functions.sh

# Yo will run as a undefined user, but not root
# Make sure he has access to anything
printf "[%12s] creating /root/.cache/bower /root/.local/share/bower\n" "setenv.sh" >> /var/log/startup_sequence
mkdir -p /root/.cache/bower
mkdir -p /root/.local/share/bower
printf "[%12s] granting access to anybody to /root/.cache /root/.local /root/.npm\n" "setenv.sh" >> /var/log/startup_sequence
chmod -R 777 /root/.cache
chmod -R 777 /root/.local
chmod -R 777 /root/.npm
ls -ail /root > /dev/null
printf "[%12s] done, now executing requested command\n" "setenv.sh" >> /var/log/startup_sequence

exec "$@"
