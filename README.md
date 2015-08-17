# maven-angular

This images contains all the dependencies required to work with the
[yeoman-maven-plugin](https://github.com/trecloux/yeoman-maven-plugin).
The target audience is people working in corporations setting numerous traps
for front-end javascript developers such as (non-exhaustive list): developping
on a Windows workstation, located behind a proxy, using a private maven
repository and so on.

## Forewords about Windows + Vagrant + Docker

Windows users running docker container inside a vagrant guest VM will
experience **a lot of issues** when using this image with synced folders. It
might be possible to make it work, if symbolic links and long paths can be
enabled.

Open `secpol.msc`, navigate to `local strategies`, `user rights` and check who
can `create symbolic links`. For Windows 7, the default value seems to be
`Administrator` only. Run `git bash` or `cygwin` (or any other command line
program used to boot vagrant) as Administrator. Now you should be able to
create symbolic links.

If you cannot run vagrant with symbolic link creation right, then it would be
better to stop here. It would probably be far more easier to virtualize
a GNU/Linux end-user distribution on the Windows host.

Now that symbolic links are enabled on the Windows host, configure vagrant to
mount a shared folder using the Windows long path support and symbolic links.
Add the following options in the Vagrantfile:

```ruby
# Replace 'vagrant' by the user name used when logging in the guest
$mount_sharedfolder = <<EOS
[ -d /z ] || mkdir /z
mount -t vboxsf -o uid=$(id -u vagrant),gid=$(cat /etc/group | grep -E '^vagrant' | cut -d: -f3) www /z
EOS

Vagrant.configure("2") do |config|
    # ...
    config.vm.provider "virtualbox" do |vb|
        # Adapt the following example to your file structure.
        # In this example, we assume to have a 'www' subdir in the current dir.
        vb.customize ["sharedfolder", "add", :id, "--name", "www", "--hostpath", (("//?/" + File.dirname(__FILE__) + "/www").gsub("/","\\"))]
        # This is to enable symbolic links
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/www", "1"]
		# ...
    end
	# ...

    config.vm.provision :shell, inline: $mount_sharedfolder, run: "always"
end
```

This workaround is adapted from the [npm wiki, section
troubleshooting](https://github.com/npm/npm/wiki/Troubleshooting#running-a-vagrant-box-on-windows-fails-due-to-path-length-issues)
and many other resources found on the web.

## Always use bash to run build commands

Build commands require bash. And .bashrc must be sourced, so either start the
container without any command such as:

```sh
docker run --rm -it pbarnoux/maven-angular
```

Or override it with a custom command running in a *login* bash shell, such as:

```sh
docker run --rm -it pbarnoux/maven-angular /bin/bash -cl 'mvn ...'
```

This also apply to command started by docker-compose, in the yml file, use:

```yml
goal:
  image: pbarnoux/maven-angular
  command: /bin/bash -cl 'mvn ...'
```

## Running yo and npm

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
# run yo
#   angular, sass: n, bootstrap: y, default options
#   overwrite package.json: y
yo [angular]
```

#### Windows + Vagrant + Docker

When running yo, you quickly encounter a prompt requiring to indicate whether
you want to overwrite the package.json file or not. Wait for the first install
wave to finish, a `Done without error` should be displayed in the console,
before typing 'y'. It will trigger a second `npm install`.  Answering too
quickly to this prompt may bring random write errors in the /root/.npm folder
such as:

npm ERR! untar error /root/.npm/

### Running npm install to install dependencies in an existing project

Start the container:

```sh
docker run --rm -it pbarnoux/maven-angular
```

Inside the container:

```sh
# npm is an alias to a wrapper bash script
alias npm
# run npm
npm install
```

#### Windows + Vagrant + Docker + Proxy

It will detect if your current directory is a vboxsf filesystem, and if so, it
will perform the npm install in the /tmp folder instead. Moving back the
generated dependencies may take some minutes.

The reason behind this is that when a proxy is detected, imagemin dependencies
must be downloaded as source tarballs, compiled and configured. The
configuration step is using automake and raises this kind of error on shared
drives:

./configure: cannot create temp file for here-document: Text file busy

#### Note about npm errors reported by the wrapper scripts

When starting yo from the wrapper shell script with an environment variable
`http_proxy` set, the shell script will attempt to downgrade bin-build to the
2.1.1 version.

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

#### Windows + Vagrant + Docker

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

#### Windows + Vagrant + Docker

Windows users running docker container inside a vagrant guest VM should add the
following line to their Vagrantfile:

```ruby
Vagrant.configure("2") do |config|
    # ...
    config.vm.synced_folder "#{ENV['HOME']}/.m2", "/home/vagrant/.m2"
end
```

Replace `vagrant` with the correct user name if your VM is configured to use
another login name.

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
    command: /bin/bash -cl 'mvn install && mvn ...'

othergoal:
	image: pbarnoux/maven-angular
	...
```

Then to run the maven install, the command is:

```sh
docker-compose run --rm --service-ports deploywar [alternative command]
```

Note that:
- running docker or docker-compose with the run argument loads /bin/sh. To make
  sure to loads the environment, use /bin/bash *-cl* 'your command' to start
  bash as a login shell;
- the --service-ports flag is mandatory only if you want to forward ports.

### Included software licence

This image ships with an Oracle JDK 8. By using this image, or any image
deriving from this one, you implicetely accept the [Oracle JDK software
licence](http://java.com/license).

In order to save space in the resulting image, sources and manual have been
removed. You can download them from [Oracle
website](http://www.oracle.com/technetwork/java/javase/downloads/index.html).
