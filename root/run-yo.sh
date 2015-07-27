# Resources available on web explaining why yo might need additional commands
# to run
why_downgrade_bin_build="https://github.com/npm/npm/issues/8682"
ver_bin_build=2.1.1

printf "\n***** yo wrapper *****\n"

if [ ! -z "yo_dir" -a -d "$yo_dir" ]; then
	printf "\n* yo_dir variable set, running yo in '%s'\n" "$yo_dir"
	cd "$yo_dir"
else
	printf "\n* yo_dir variable not set, running in current dir\n"
fi
# Defined in /root/.bashrc
check_bin_build
printf "\n***** end of wrapper *****\n\n"
exec "/usr/bin/yo" "$@"

