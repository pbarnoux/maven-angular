printf "[%12s] exporting functions\n" "functions.sh" >> /var/log/startup_sequence
# Check if a dependency is installed locally
# $1: the dependency name
# $2: the dependency version
# $3: the maximun depth level to look for
is_installed_locally()
{
	/usr/bin/npm list --depth=$3 --json=true $1 \
		| grep -qE "\W*version[^\w\d]+$2[^\w\d]+" && return 0
	return 1
}

downgrade_bin_build()
{
	# Resources available on web explaining why yo might need additional
	# commands to run
	why_downgrade_bin_build="https://github.com/npm/npm/issues/8682"
	v_bin_build=2.1.1

	if [ ! -z "$http_proxy" ]; then
		printf "* http_proxy variable set, using bin-build honoring proxy\n"
		# When npm list return non 0 value, this script stops
		# This was the only construction working, refactoring welcome
		is_installed_locally bin-build ${v_bin_build} 0 || ( \
			printf "* downgrading bin-build to version ${v_bin_build}\n" && \
			printf "    see $why_downgrade_bin_build\n" && \
			/usr/bin/npm install bin-build@${v_bin_build} && \
			printf "* granting full access to anybody to /root/.npm\n" && \
			chmod -R 777 /root/.npm && \
			ls -ail /root > /dev/null )
	else
		printf "* http_proxy variable not set, using default dependencies\n"
	fi
	printf "* granting full access to anybody to .\n"
	chmod -R 777 .
	ls -ail . > /dev/null
}

# Downgrade bin-build if behind a proxy
check_bin_build()
{
	# Resources available on web explaining why yo might need additional
	# commands to run
	why_downgrade_bin_build="https://github.com/npm/npm/issues/8682"
	v_bin_build=2.1.1

	if [ ! -z "$http_proxy" ]; then
		printf "* http_proxy variable set, using bin-build honoring proxy\n"
		# When npm list return non 0 value, this script stops
		# This was the only construction working, refactoring welcome
		/usr/bin/npm list --depth=0 --json=true bin-build \
			| grep -qE "\W*version[^\w\d]+${v_bin_build}[^\w\d]+" || ( \
			printf "* downgrading bin-build to version ${v_bin_build}\n" && \
			printf "    see $why_downgrade_bin_build\n" && \
			/usr/bin/npm install bin-build@${v_bin_build} && \
			printf "* granting full access to anybody to /root/.npm\n" && \
			chmod -R 777 /root/.npm && \
			ls -ail /root > /dev/null )
	else
		printf "* http_proxy variable not set, using default dependencies\n"
	fi
	printf "* granting full access to anybody to .\n"
	chmod -R 777 .
	ls -ail . > /dev/null
}

# Relocate to yo_dir
# $1: why relocation is needed
relocate_to_yo_dir()
{
	printf "* is yo_dir environment variable set? "
	if [ ! -z "yo_dir" -a -d "$yo_dir" ]; then
		printf "yes, %s in '%s'\n" "$1" "$yo_dir"
		cd "$yo_dir"
	else
		printf "no, %s in '%s'\n" "$1" "$PWD"
	fi
}

# Remove bin-build (used only when installing from scratch)
remove_bin_build()
{
	is_installed_locally bin-build 2.1.1 0 && ( \
		printf "* removing bin-build" &&
		/usr/bin/npm remove bin-build )
}

# Export functions
export -f is_installed_locally
export -f downgrade_bin_build
export -f check_bin_build
export -f relocate_to_yo_dir
export -f remove_bin_build
printf "[%12s] done\n" "functions.sh" >> /var/log/startup_sequence
