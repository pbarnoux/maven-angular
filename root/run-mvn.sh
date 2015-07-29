# handle docker-compose commands which apparently do not source .bashrc
declare -f check_bin_build > /dev/null || . /root/functions.sh
printf "\n***** mvn wrapper *****\n"
printf "\n* verify which goals are requested\n"
run_yo=1
why_run_yo=""

for goal in "$@"
do
	case "$goal" in
		prepare-package | package | pre-integration-test | integration-test | \
			post-integration-test | verify | install | deploy )
		why_run_yo="$goal"
		run_yo=0 ;;
	*) ;;
esac
done

if [ $run_yo -eq 0 ]; then
	printf "\n* Goal '%s' may trigger yeoman-maven-plugin\n" "$why_run_yo"

	if [ ! -z "$yo_dir" -a -d "$yo_dir" ]; then
		printf "\n* variable yo_dir set, using '%s'\n" "$yo_dir"
		root_dir="$yo_dir"
	else
		printf "\n* variable yo_dir not set, trying to detect yo dir\n"
		res=$(find . -name ".yo-rc.json" -exec dirname '{}' \;)

		if [ ! -z "$res" -a -d "$res" ]; then
			printf "  - found a good candidate for yo dir: '%s'\n" "$res"
			root_dir="$res"
		fi
	fi

	if [ -z "$root_dir" ]; then
		printf "\n! found no candidate for yo dir: bypassing validation steps"
	else
		initial_dir=$PWD
		cd "$root_dir"
		# Defined in /root/functions.sh
		check_bin_build
		cd "$initial_dir"
	fi
fi

printf "\n***** end of wrapper *****\n\n"
exec "/usr/bin/mvn" "$@"

