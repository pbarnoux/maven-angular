printf "[%12s] starting\n" ".bashrc" >> /var/log/startup_sequence
printf "[%12s] does /root/bin exist? " ".bashrc" >> /var/log/startup_sequence
if [ -d /root/bin ]; then
	printf "yes\n" >> /var/log/startup_sequence
	printf "[%12s] adding it to path\n" ".bashrc" >> /var/log/startup_sequence
	export PATH=/root/bin:$PATH
else
	printf "no\n" >>  /var/log/startup_sequence
fi
printf "[%12s] using path '%s'\n" ".bashrc" "$PATH" >> /var/log/startup_sequence

# Aliases
printf "[%12s] defining aliases\n" ".bashrc" >> /var/log/startup_sequence
alias bower='bower --allow-root'
# Disable analytics statistics for bower
printf "[%12s] exporting environment variables\n" ".bashrc" >> /var/log/startup_sequence
export CI="true"
printf "[%12s] done\n" ".bashrc" >> /var/log/startup_sequence
