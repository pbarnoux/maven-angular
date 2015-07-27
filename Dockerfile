FROM pbarnoux/maven-angular-base
MAINTAINER Pierre Barnoux <pbarnoux@gmail.com>

ENV http_proxy=http://proxy:3128 https_proxy=http://proxy:3128
# Additional dependencies required to run yo angular with default options
RUN apt-get update && apt-get install -y --no-install-recommends \
# post build configuration step of gifsicle-bin@3.0.1
	autoconf \
# post build configuration step of optipng-bin@3.0.2
	zlib1g-dev

ENV http_proxy= https_proxy=

COPY "/root/*" "/root/"
ENTRYPOINT ["/bin/bash", "/root/setenv.sh"]
CMD ["/bin/bash"]

