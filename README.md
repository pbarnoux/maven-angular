# maven-angular

This images contains all the dependencies required to work with the
[yeoman-maven-plugin](https://github.com/trecloux/yeoman-maven-plugin).
The target audience is people working in corporations setting numerous traps
for front-end javascript developers such as (non-exhaustive list): developping
on a Windows workstation, located behind a proxy, using a private maven
repository and so on.

## Running yo to scaffold a new angular project

### Indicate that npm must use a proxy

Start the container and specify an http_proxy environment variable:

```sh
docker run --rm -it -e http_proxy="$http_proxy" pbarnoux/maven-angular
```

The variable `https_proxy` is also supported in the same way. If `http_proxy`
is the only variable set, npm will be configured to use this proxy for both
`http` and `https` protocols.

### Generate a new project with yo

Start the container:

```sh
docker run --rm -it pbarnoux/maven-angular
```

Inside the container:

```sh
# yo is an alias to a wrapper bash script
alias yo
# run yo
#   angular, sass: n, bootstrap: y, default options
#   overwrite package.json: y
yo [angular]
```

Should complete without any error, building the required dependencies if
needed.

### Note about npm errors reported by the wrapper scripts

When starting yo from the wrapper shell script (aliased 'yo') with an
environment variable `http_proxy` set, the shell script will attempt to
downgrade bin-build to the 2.1.1 version.

The following npm errors may be reported in the console:
- `npm ERR! code 1` the first time yo is scaffolding the project;
- `npm ERR! extraneous: bin-build@2.1.1 ...` when running subsequent yo
  commands.

These lines are print by the `npm list` command ran by the script.
Unfortunately, my limited knowledge about npm did not permit to keep a clean
log without breaking something in the bash script.

## Running maven to build the project

Integrate the `yeoman-maven-plugin` in your project and configure it to run
bower as root:

```xml
<plugin>
	<groupId>com.github.trecloux</groupId>
	<artifactId>yeoman-maven-plugin</artifactId>
	<version>0.4</version>
	<executions>
		<execution>
			<goals>
				<goal>build</goal>
			</goals>
		</execution>
	</executions>
	<configuration>
		<bowerInstallArgs>install --no-color --allow-root</bowerInstallArgs>
	</configuration>
</plugin>
```

Run the container and mount the maven project in a volume:

```sh
docker run --rm -it -v $PWD:/usr/src/app pbarnoux/maven-angular
```

Inside the container:

```sh
# mvn is an alias to a wrapper bash script
alias mvn
# run maven once yo has scaffolded your project
mvn clean install
```

### Redirect ports when deploying in a server

Developpers deploying their war in container managed by some maven plugin may
want to access their application from their host. Configure port forwarding to
do so:

```sh
docker run --rm -it -p 8080:8080 pbarnoux/maven-angular
```

Inside the container start the maven plugin deploying your war in a server:

```sh
mvn some_plugin:run
```

Windows users running docker container inside a vagrant guest VM should add the
following line to their Vagrantfile:

```ruby
Vagrant.configure("2") do |config|
    # ...
	config.vm.network "forwarded_port", guest: 8080, host: 31415
end
```

The application should then be accessible from localhost:31415.

### Avoid downloading the Internet when building with Maven

Start the container and mount a volume pointing to your local $HOME/.m2 folder:

```sh
docker run --rm -it -v /home/vagrant/.m2:/root/.m2 pbarnoux/maven-angular
```

Windows users running docker container inside a vagrant guest VM should add the
following line to their Vagrantfile:

```ruby
Vagrant.configure("2") do |config|
    # ...
    config.vm.synced_folder "#{ENV['HOME']}/.m2", "/home/vagrant/.m2"
end
```

## Blending everything with docker compose

Specifying volumes, ports and environment variables for each docker command may
become cumbersome at some point. Drop a docker-compose.yml file at the root of
the project and define some goals, for instance:

```yml
deploywar:
    image: pbarnoux/maven-angular
    volumes:
        - $HOME/.m2:/root/.m2
        - .:/usr/src/app
    ports:
        - "8080:8080"
    working_dir: /usr/src/app
    environment:
        http_proxy: http://proxy-host:31415
        yo_dir: /usr/src/app/my_war_module/yo
    command: /bin/bash -c '/root/run-mvn.sh install && /root/run-mvn.sh ...'

othergoal:
	image: pbarnoux/maven-angular
	...
```

Then to run the maven install, the command is:

```sh
docker-compose run --rm --service-ports deploywar [alternative command]
```

Note that:
- commands run by docker-compose seem to not source .bashrc disabling aliases
  for yo and mvn. Use their respective wrappers in /root instead;
- the --service-ports flag is mandatory only if you want to forward ports.

### Included software licence

This image ships with an Oracle JDK 8. By using this image, or any image
deriving from this one, you implicetely accept the [Oracle JDK software
licence](http://java.com/license).

In order to save space in the resulting image, sources and manual have been
removed. You can download them from [Oracle
website](http://www.oracle.com/technetwork/java/javase/downloads/index.html).
