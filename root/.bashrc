# Methods
check_bin_build()
{
	# Resources available on web explaining why yo might need additional
	# commands to run
	why_downgrade_bin_build="https://github.com/npm/npm/issues/8682"
	v_bin_build=2.1.1

	if [ ! -z "$http_proxy" ]; then
		printf "> http_proxy variable set, using bin-build honoring proxy\n"
		# Downgrade bin-build if not already present
		npm list --depth=0 --json=true bin-build \
			| grep -qE "\W*version[^\w\d]+${v_bin_build}[^\w\d]+" || ( \
			printf "  - downgrading bin-build to version ${v_bin_build}\n" && \
			printf "    see $why_downgrade_bin_build\n" && \
			npm install bin-build@${v_bin_build}
		)
	else
		printf "> http_proxy variable not set, using default dependencies\n"
	fi
	printf "> granting full access to anybody to . and /root/.npm\n"
	chmod -R 777 . /root/.npm
}
export -f check_bin_build

# Aliases
alias yo='/root/run-yo.sh'
alias mvn='/root/run-mvn.sh'

