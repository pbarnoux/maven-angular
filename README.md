# maven-angular

This images targets people working in corporations setting numerous traps for
front-end javascript developers such as (non-exhaustive list): developping on
a Windows workstation, located behind a proxy, using a private maven repository
and so on.

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

### Indicate that npm must use a proxy

Start the container and specify an http_proxy environment variable:

```sh
docker run --rm -it -e http_proxy="$http_proxy" pbarnoux/maven-angular
```

The variable `https_proxy` is also supported in the same way. If `http_proxy`
is the only variable set, npm will be configured to use this proxy for both
`http` and `https` protocols.

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

### TODO

- Provide documentation to run yo through the maven plugin.
