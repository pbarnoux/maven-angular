# handle docker-compose commands which apparently do not source .bashrc
declare -f check_bin_build > /dev/null || . /root/functions.sh
printf "\n***** yo wrapper *****\n"

if [ ! -z "yo_dir" -a -d "$yo_dir" ]; then
	printf "\n* yo_dir variable set, running yo in '%s'\n" "$yo_dir"
	cd "$yo_dir"
else
	printf "\n* yo_dir variable not set, running in current dir\n"
fi
# Defined in /root/functions.sh
check_bin_build
printf "\n***** end of wrapper *****\n\n"
exec "/usr/bin/yo" "$@"

