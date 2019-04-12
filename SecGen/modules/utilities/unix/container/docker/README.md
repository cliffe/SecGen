[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-docker.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-docker)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppetlabs/docker.svg)](https://forge.puppetlabs.com/puppetlabs/docker)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppetlabs/docker.svg)](https://forge.puppetlabs.com/puppetlabs/docker)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/puppetlabs/docker.svg)](https://forge.puppetlabs.com/puppetlabs/docker)


# Docker

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
   * [Images](#images)
   * [Containers](#containers)
   * [Networks](#networks)
   * [Volumes](#volumes)
   * [Compose](#compose)
   * [Swarm mode](#swarmmode)
   * [Tasks](#tasks)
   * [Docker services](#dockerservices)
   * [Private registries](#privateregistries)
   * [Exec](#exec)
   * [Plugins](#plugins)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
   * [Classes](#classes)
   * [Defined types](#definedtypes)
   * [Types](#types)
   * [Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The Puppet docker module installs, configures, and manages [Docker](https://github.com/docker/docker) from the [Docker repository](https://docs.docker.com/installation/). It supports the latest [Docker CE (Community Edition)](https://www.docker.com/community-edition) for Linux based distributions and [Docker EE(Enterprise Edition)](https://www.docker.com/enterprise-edition) for Windows and Linux as well as legacy releases.


## Description

This module install, configures, and manages [Docker](https://github.com/docker/docker).

Due to the new naming convention for Docker packages, this module prefaces any params that refer to the release with `_ce` or `_engine`. Examples of these are documented in this README.

## Setup

To create the Docker hosted repository and install the Docker package, add a single class to the manifest file:

```puppet
include 'docker'
```

To configure package sources independently and disable automatically including sources, add the following code to the manifest file:

```puppet
class { 'docker':
  use_upstream_package_source => false,
}
```

The latest Docker [repositories](https://docs.docker.com/engine/installation/linux/docker-ce/debian/#set-up-the-repository) are now the default repositories for version 17.06 and above. If you are using an older version, the repositories are still configured based on the version number passed into the module.

To ensure the module configures the latest repositories, add the following code to the manifest file:

```puppet
class { 'docker':
  version => '17.09.0~ce-0~debian',
}
```

Using a version prior to 17.06, configures and installs from the old repositories:

```puppet
class { 'docker':
  version => '1.12.0-0~wheezy',
}
```

Docker provides a enterprise addition of the [Docker Engine](https://www.docker.com/enterprise-edition), called Docker EE. To install Docker EE on Debian systems, add the following code to the manifest file:

```puppet
class { 'docker':
  docker_ee => true,
  docker_ee_source_location => 'https://<docker_ee_repo_url>',
  docker_ee_key_source => 'https://<docker_ee_key_source_url>',
  docker_ee_key_id => '<key id>',
}
```

To install Docker EE on RHEL/CentOS:

```puppet
class { 'docker':
  docker_ee => true,
  docker_ee_source_location => 'https://<docker_ee_repo_url>',
  docker_ee_key_source => 'https://<docker_ee_key_source_url>',
}
```

For CentOS distributions, the docker module requires packages from the extras repository which is enabled by default on CentOS. For more information, see the official [CentOS documentation](https://wiki.centos.org/AdditionalResources/Repositories) and the official [Docker documentation](https://docs.docker.com/install/linux/docker-ce/centos/).

For Red Hat Enterprise Linux (RHEL) based distributions, the docker module uses the upstream repositories. To continue using the legacy distribution packages in the CentOS extras repository, add the following code to the manifest file:

```puppet
class { 'docker':
  use_upstream_package_source => false,
  service_overrides_template  => false,
  docker_ce_package_name      => 'docker',
}
```

To use the CE packages, add the following code to the manifest file:

```puppet
class { 'docker':
  use_upstream_package_source => false,
  repo_opt => '',  
}
```

By default, the Docker daemon binds to a unix socket at `/var/run/docker.sock`. To change this parameter and update the binding parameter to a tcp socket, add the following code to the manifest file:

```puppet
class { 'docker':
  tcp_bind        => ['tcp://127.0.0.1:4243','tcp://10.0.0.1:4243'],
  socket_bind     => 'unix:///var/run/docker.sock',
  ip_forward      => true,
  iptables        => true,
  ip_masq         => true,
  bridge          => br0,
  fixed_cidr      => '10.20.1.0/24',
  default_gateway => '10.20.0.1',
}
```

When setting up TLS, upload the related files (CA certificate, server certificate, and key) and include their paths in the manifest file:

```puppet
class { 'docker':
  tcp_bind        => ['tcp://0.0.0.0:2376'],
  tls_enable      => true,
  tls_cacert      => '/etc/docker/tls/ca.pem',
  tls_cert        => '/etc/docker/tls/cert.pem',
  tls_key         => '/etc/docker/tls/key.pem',
}
```

To specify which Docker rpm package to install, add the following code to the manifest file:

```puppet
class { 'docker' :
  manage_package              => true,
  use_upstream_package_source => false,
  package_engine_name         => 'docker-engine'
  package_source_location     => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
  prerequired_packages        => [ 'glibc.i686', 'glibc.x86_64', 'sqlite.i686', 'sqlite.x86_64', 'device-mapper', 'device-mapper-libs', 'device-mapper-event-libs', 'device-mapper-event' ]
}
```

To track the latest version of Docker, add the following code to the manifest file:

```puppet
class { 'docker':
  version => 'latest',
}
```

To install docker from a test or edge channel, add the following code to the manifest file:

```puppet
class { 'docker':
  docker_ce_channel => 'test'
}
```

To allocate a dns server to the Docker daemon, add the following code to the manifest file:

```puppet
class { 'docker':
  dns => '8.8.8.8',
}
```

To add users to the Docker group, add the following array to the manifest file:

```puppet
class { 'docker':
  docker_users => ['user1', 'user2'],
}
```

To add daemon labels, add the following array to the manifest file:

```puppet
class { 'docker':
  labels => ['storage=ssd','stage=production'],
}
```

To uninstall docker, add the following to the manifest file:

```puppet
class { 'docker':
  ensure => absent
}
```

Only Docker EE is supported on Windows. To install docker on Windows 2016 and above the `docker_ee` parameter must be specified: 
```puppet
class { 'docker':
  docker_ee => true
}
```

### Proxy on Windows
To use docker through a proxy on Windows, a System Environment Variable HTTP_PROXY/HTTPS_PROXY must be set. See [Docker Engine on Windows](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon#proxy-configuration)
This can be done using a different puppet module such as the puppet-windows_env module. After setting the variable, the docker service must be restarted.
```puppet
windows_env { 'HTTP_PROXY'
  value  => 'http://1.2.3.4:80',
  notify => Service['docker'],
}
windows_env { 'HTTPS_PROXY'
  value  => 'http://1.2.3.4:80',
  notify => Service['docker'],
}
service { 'docker'
  ensure => 'running',
}
````

## Usage

### Images

Each image requires a unique name; otherwise, the installation fails when a duplicate name is detected.

To install a Docker image, add the `docker::image` defined type to the manifest file:

```puppet
docker::image { 'base': }
```

The code above is equivalent to running the `docker pull base` command. However, it removes the default five-minute execution timeout.

To include an optional parameter for installing image tags that is the equivalent to running `docker pull -t="precise" ubuntu`, add the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  image_tag => 'precise'
}
```

Including the `docker_file` parameter is equivalent to running the `docker build -t ubuntu - < /tmp/Dockerfile` command. To add or build an image from a dockerfile that includes the `docker_file` parameter, add the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  docker_file => '/tmp/Dockerfile'
}
```

Including the `docker_dir` parameter is equivalent to running the `docker build -t ubuntu /tmp/ubuntu_image` command. To add or build an image from a dockerfile that includes the `docker_dir` parameter, add the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  docker_dir => '/tmp/ubuntu_image'
}
```

To rebuild an image, subscribe to external events such as Dockerfile changes by adding the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  docker_file => '/tmp/Dockerfile'
  subscribe => File['/tmp/Dockerfile'],
}

file { '/tmp/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/someModule/Dockerfile',
}
```

To remove an image, add the following code to the manifest file:

```puppet
docker::image { 'base':
  ensure => 'absent'
}

docker::image { 'ubuntu':
  ensure    => 'absent',
  image_tag => 'precise'
}
```

To configure the `docker::images` class when using Hiera, add the following code to the manifest file:

```yaml
---
  classes:
    - docker::images

docker::images::images:
  ubuntu:
    image_tag: 'precise'
```

### Containers

To launch containers, add the following code to the manifest file:

```puppet
docker::run { 'helloworld':
  image   => 'base',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

This is equivalent to running the  `docker run -d base /bin/sh -c "while true; do echo hello world; sleep 1; done"` command to launch a Docker container managed by the local init system.

`run` includes a number of optional parameters:

```puppet
docker::run { 'helloworld':
  image            => 'base',
  detach           => true,
  service_prefix   => 'docker-',
  command          => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
  ports            => ['4444', '4555'],
  expose           => ['4666', '4777'],
  links            => ['mysql:db'],
  net              => 'my-user-def-net',
  disable_network  => false,
  volumes          => ['/var/lib/couchdb', '/var/log'],
  volumes_from     => '6446ea52fbc9',
  memory_limit     => '10m', # (format: '<number><unit>', where unit = b, k, m or g)
  cpuset           => ['0', '3'],
  username         => 'example',
  hostname         => 'example.com',
  env              => ['FOO=BAR', 'FOO2=BAR2'],
  env_file         => ['/etc/foo', '/etc/bar'],
  labels           => ['com.example.foo="true"', 'com.example.bar="false"'],
  dns              => ['8.8.8.8', '8.8.4.4'],
  restart_service  => true,
  privileged       => false,
  pull_on_start    => false,
  before_stop      => 'echo "So Long, and Thanks for All the Fish"',
  before_start     => 'echo "Run this on the host before starting the Docker container"',
  after            => [ 'container_b', 'mysql' ],
  depends          => [ 'container_a', 'postgres' ],
  stop_wait_time   => 0,
  read_only        => false,
  extra_parameters => [ '--restart=always' ],
}
```

You can specify the `ports`, `expose`, `env`, `dns`, and `volumes` values with a single string or an array.

To pull the image before it starts, specify the `pull_on_start` parameter.

To execute a command before the container stops, specify the `before_stop` parameter.

Adding the container name to the `after` parameter to specify which containers start first, affects the generation of the `init.d/systemd` script.

Add container dependencies to the `depends` parameter. The container starts before this container and stops before the depended container. This affects the generation of the `init.d/systemd` script. Use the `depend_services` parameter to specify dependencies for general services, which are not Docker related, that start before this container.

The `extra_parameters` parameter, which contains an array of command line arguments to pass to the `docker run` command, is useful for adding additional or experimental options that the docker module currently does not support.

By default, automatic restarting of the service on failure is enabled by the service file for systemd based systems.

It's recommended that an image tag is used at all times with the `docker::run` define type. If not, the latest image ise used, whether it be in a remote registry or installed on the server already by the `docker::image` define type. 

NOTE: As of v3.0.0, if the latest tag is used, the image will be the latest at the time the of the initial puppet run. Any subsequent puppet runs will always reference the latest local image. For this this reason it highly recommended that an alternative tag be used, or the image be removed before pulling latest again. 

To use an image tag, add the following code to the manifest file:

```puppet
docker::run { 'helloworld':
  image   => 'ubuntu:precise',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

By default, when the service stops or starts, the generated init scripts remove the container, but not the associated volumes. To change this behaviour, add the following code to the manifest file:

```puppet
docker::run { 'helloworld':
  remove_container_on_start => true,
  remove_volume_on_start    => false,
  remove_container_on_stop  => true,
  remove_volume_on_stop     => false,
}
```

If using Hiera, you can configure the `docker::run_instance` class:

```yaml
---
  classes:
    - docker::run_instance

  docker::run_instance::instance:
    helloworld:
      image: 'ubuntu:precise'
      command: '/bin/sh -c "while true; do echo hello world; sleep 1; done"'
```

To remove a running container, add the following code to the manifest file. This also removes the systemd service file associated with the container.

```puppet
docker::run { 'helloworld':
  ensure => absent,
}
```

To enable the restart of an unhealthy container, add the following code to the manifest file. In order to set the health check interval time set the optional health_check_interval parameter, the default health check interval is 30 seconds.

```puppet
docker::run { 'helloworld':
  image => 'base',
  command => 'command',
  health_check_cmd => '<command_to_execute_to_check_your_containers_health>',
  restart_on_unhealthy => true,
  health_check_interval => '<time between running docker healthcheck>',
```

To run command on Windows 2016 requires the `restart` parameter to be set:
```puppet
docker::run { 'helloworld':
  image => 'microsoft/nanoserver',
  command => 'ping 127.0.0.1 -t',
  restart => 'always'
```

### Networks

Docker 1.9.x supports networks. To expose the `docker_network` type that is used to manage networks, add the following code to the manifest file:

```puppet
docker_network { 'my-net':
  ensure   => present,
  driver   => 'overlay',
  subnet   => '192.168.1.0/24',
  gateway  => '192.168.1.1',
  ip_range => '192.168.1.4/32',
}
```

The name value and the `ensure` parameter are required. If you do not include the `driver` value, the default bridge is used. The Docker daemon must be configured for some networks and configuring the cluster store for the overlay network would be an example.

To configure the cluster store, update the `docker` class in the manifest file:

```puppet
extra_parameters => '--cluster-store=<backend>://172.17.8.101:<port> --cluster-advertise=<interface>:2376'
```

If using Hiera, configure the `docker::networks` class in the manifest file:

```yaml
---
  classes:
    - docker::networks

docker::networks::networks:
  local-docker:
    ensure: 'present'
    subnet: '192.168.1.0/24'
    gateway: '192.168.1.1'
```

A defined network can be used on a `docker::run` resource with the `net` parameter.

#### Windows

On windows, only one NAT network is supported. To support multiple networks, Windows Server 2016 with KB4015217 is required. See [Windows Container Network Drivers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/container-networking/network-drivers-topologies) and [Windows Container Networking](https://docs.microsoft.com/en-us/virtualization/windowscontainers/container-networking/architecture).

The Docker daemon will create a default NAT network on the first start unless specified otherwise. To disable the network creation, use the parameter `bridge => 'none'` when installing docker.

### Volumes

Docker 1.9.x added support for volumes. These are *NOT* to be confused with the legacy volumes, now known as `bind mounts`. To expose the `docker_volume` type, which is used to manage volumes, add the following code to the manifest file:

```puppet
docker_volume { 'my-volume':
  ensure => present,
}
```

The name value and the `ensure` parameter are required. If you do not include the `driver` value, the default `local` is used.

If using Hiera, configure the `docker::volumes` class in the manifest file:

```yaml
---
  classes:
    - docker::volumes::volumes

docker::volumes::volumes:
  blueocean:
    ensure: present
    driver: local
    options:
      - ['type=nfs','o=addr=%{custom_manager},rw','device=:/srv/blueocean']
```

Any extra options should be passed in as an array

Some of the key advantages for using `volumes` over `bind mounts` are:
* Easier to back up or migrate rather than `bind mounts` (legacy volumes).
* Managed with Docker CLI or API (Puppet type uses the CLI commands).
* Works on Windows and Linux.
* Easily shared between containers.
* Allows for store volumes on remote hosts or cloud providers.
* Encrypt contents of volumes.
* Add other functionality
* New volume's contents can be pre-populated by a container.

When using the `volumes` array with `docker::run`, the command on the backend will know if it needs to use `bind mounts` or `volumes` based off the data passed to the `-v` option.

Running `docker::run` with native volumes:

```puppet
docker::run { 'helloworld':
  image   => 'ubuntu:precise',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
  volumes => ['my-volume:/var/log'],
}
```

For more information on volumes see the [Docker Volumes](https://docs.docker.com/engine/admin/volumes/volumes) documentation.

### Compose

Docker Compose describes a set of containers in YAML format and runs a command to build and run those containers. Included in the docker module is the `docker_compose` type. This enables Puppet to run Compose and remediate any issues to ensure reality matches the model in your Compose file.

Before you use the `docker_compose` type, you must install the Docker Compose utility.

To install Docker Compose, add the following code to the manifest file:

```puppet
class {'docker::compose':
  ensure => present,
  version => '1.9.0',
}
```
Set the `version` parameter to any version you need to install.

This is an example of a Compose file:

```yaml
compose_test:
  image: ubuntu:14.04
  command: /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

Specify the `file` resource to add a Compose file to the machine you have Puppet running on. To define a `docker_compose` resource pointing to the Compose file, add the following code to the manifest file:

```puppet
docker_compose { 'test':
  compose_files => ['/tmp/docker-compose.yml'],
  ensure  => present,
}
```

Puppet automatically runs Compose, because the relevant Compose services aren't running. If required, include additional options such as enabling experimental features and scaling rules.

In the example below, Puppet runs Compose when the number of containers specified for a service doesn't match the scale values.

```puppet
docker_compose { 'test':
  compose_files => ['/tmp/docker-compose.yml'],
  ensure  => present,
  scale   => {
    'compose_test' => 2,
  },
  options => '--x-networking'
}
```

Give options to the ```docker-compose up``` command, such as ```--remove-orphans```, by using the ```up_args``` option.

To supply multiple overide compose files add the following to the manifest file:

```puppet
docker_compose {'test':
  compose_files => ['master-docker-compose.yml', 'override-compose.yml],
}
```

Please note you should supply your master docker-compose file as the first element in the array. As per docker, multi compose file support compose files are merged in the order they are specified in the array.

If you are using a v3.2 compose file or above on a Docker Swarm cluster, use the `docker::stack` class. Include the file resource before you run the stack command.

To deploy the stack, add the following code to the manifest file:

```puppet
 docker::stack { 'yourapp':
   ensure  => present,
   stack_name => 'yourapp',
   compose_files => ['/tmp/docker-compose.yaml'],
   require => [Class['docker'], File['/tmp/docker-compose.yaml']],
}
```

To remove the stack, set `ensure  => absent`.

If you are using a v3.2compose file or above on a Docker Swarm cluster, include the `docker::stack` class. Similar to using older versions of Docker, compose the file resource before running the stack command. 

To deploy the stack, add the following code to the manifest file.

```puppet
docker::stack { 'yourapp':
  ensure  => present,
  stack_name => 'yourapp',
  compose_files => ['/tmp/docker-compose.yaml'],
  require => [Class['docker'], File['/tmp/docker-compose.yaml']],
}
```
To remove the stack, set `ensure  => absent`.

### Swarm mode

To natively manage a cluster of Docker Engines known as a swarm, Docker Engine 1.12 includes a swarm mode.

To cluster your Docker engines, use one of the following Puppet resources:

* [Swarm manager](#Swarm-manager)
* [Swarm worker](#Swarm-worker)

#### Windows

To configure swarm, Windows Server 2016 requires KB4015217 and the following firewall ports to be open on all nodes:

* TCP port 2377 for cluster management communications
* TCP and UDP port 7946 for communication among nodes
* UDP port 4789 for overlay network traffic

#### Swarm manager

To configure the swarm manager, add the following code to the manifest file:

```puppet
docker::swarm {'cluster_manager':
  init           => true,
  advertise_addr => '192.168.1.1',
  listen_addr    => '192.168.1.1',
}
```

For a multihomed server and to enable cluster communications between the node, include the ```advertise_addr``` and ```listen_addr``` parameters.

#### Swarm worker

To configure the swarm worker, add the following code to the manifest file:

```puppet
docker::swarm {'cluster_worker':
join           => true,
advertise_addr => '192.168.1.2',
listen_addr    => '192.168.1.2,
manager_ip     => '192.168.1.1',
token          => 'your_join_token'
}
```

To configure a worker node or a second manager, include the swarm manager IP address in the `manager_ip` parameter. To define the role of the node in the cluster, include the `token` parameter. When creating an additional swarm manager and a worker node, separate tokens are required.

To remove a node from a cluster, add the following code to the manifest file:

```puppet
docker::swarm {'cluster_worker':
ensure => absent
}
```

### Tasks

The docker module has an example task that allows a user to initialize, join and leave a swarm.

```puppet
bolt task run docker::swarm_init listen_addr=172.17.10.101 adverstise_addr=172.17.10.101 ---nodes swarm-master --user <user> --password <password> --modulepath <module_path>

docker swarm init --advertise-addr=172.17.10.101 --listen-addr=172.17.10.101
Swarm initialized: current node (w8syk0g286vd7d9kwzt7jl44z) is now a manager.
```

To add a worker to this swarm, run the following command:

```puppet
    docker swarm join --token SWMTKN-1-317gw63odq6w1foaw0xkibzqy34lga55aa5nbjlqekcrhg8utl-08vrg0913zken8h9vfo4t6k0t 172.17.10.101:2377
```

To add a manager to this swarm, run `docker swarm join-token manager` and follow the instructions.

```puppet
Ran on 1 node in 4.04 seconds
```

```puppet
bolt task run docker::swarm_token node_role=worker ---nodes swarm-master --user <user> --password <password> --modulepath <module_path>

SWMTKN-1-317gw63odq6w1foaw0xkibzqy34lga55aa5nbjlqekcrhg8utl-08vrg0913zken8h9vfo4t6k0t

Ran on 1 node in 4.02 seconds
```

```puppet
bolt task run docker::swarm_join listen_addr=172.17.10.102 adverstise_addr=172.17.10.102 token=<swarm_token> manager_ip=172.17.10.101:2377 --nodes swarm-02 --user root --password puppet --modulepath /tmp/modules

This node joined a swarm as a worker.

Ran on 1 node in 4.68 seconds
```

```puppet
bolt task run docker::swarm_leave --nodes swarm-02 --user root --password puppet --modulepath --modulepath <module_path>

Node left the swarm.

Ran on 1 node in 6.16 seconds
```

### Docker services

Docker services create distributed applications across multiple swarm nodes. Each Docker service replicates a set of containers across the swarm.

To create a Docker service, add the following code to the manifest file:

```puppet
docker::services {'redis':
    create => true,
    service_name => 'redis',
    image => 'redis:latest',
    publish => '6379:639',
    replicas => '5',
    extra_params => ['--update-delay 1m', '--restart-window 30s']
  }
```

To base the service off an image, include the `image` parameter and include the `publish` parameter to expose the service ports. To set the amount of containers running in the service, include the `replicas` parameter. For information regarding the `extra_params` parameter, see `docker service create --help`.

To update the service, add the following code to the manifest file:

```puppet
docker::services {'redis_update':
  create => false,
  update => true,
  service_name => 'redis',
  replicas => '3',
}
```

To update a service without creating a new one, include the the `update => true` parameter and the `create => false` parameter.

To scale a service, add the following code to the manifest file:

```puppet
docker::services {'redis_scale':
  create => false,
  scale => true,
  service_name => 'redis',
  replicas => '10',
}
```

To scale the service without creating a new one, include the the `scale => true` parameter and the `create => false` parameter. In the example above, the service is scaled to 10.

To remove a service, add the following code to the manifest file:

```puppet
docker::services {'redis':
  create => false,
  ensure => 'absent',
  service_name => 'redis',
}
```

To remove the service from a swarm, include the `ensure => absent` parameter and the `service_name` parameter.

### Private registries

When a server is not specified, images are pushed and pulled from [index.docker.io](https://index.docker.io). To qualify your image name, create a private repository without authentication.

To configure authentication for a private registry, add the following code to the manifest file, depending on what version of Docker you are running. If you are using Docker V1.10 or earlier, specify the docker version in the manifest file:

```puppet
docker::registry { 'example.docker.io:5000':
  username => 'user',
  password => 'secret',
  email    => 'user@example.com',
  version  => '<docker_version>'
}
```

To pull images from the docker store, use the following as the registry definition with your own docker hub credentials

```puppet
  docker::registry {'https://index.docker.io/v1/':
    username => 'username',
    password => 'password',
  }
```

If using hiera, configure the `docker::registry_auth` class:

```yaml
docker::registry_auth::registries:
  'example.docker.io:5000':
    username: 'user1'
    password: 'secret'
    email: 'user1@example.io'
    version: '<docker_version>'
```

If using Docker V1.11 or later, the docker login email flag has been deprecated [docker_change_log](https://docs.docker.com/release-notes/docker-engine/#1110-2016-04-13). 

Add the following code to the manifest file:

```puppet
docker::registry { 'example.docker.io:5000'}
  username => 'user',
  password => 'secret',
}
```

If using hiera, configure the 'docker::registry_auth' class:

```yaml
docker::registry_auth::registries:
  'example.docker.io:5000':
    username: 'user1'
    password: 'secret'
```

To log out of a registry, add the following code to the manifest file:

```puppet
docker::registry { 'example.docker.io:5000':
  ensure => 'absent',
}
```

To set a preferred registry mirror, add the following code to the manifest file:

```puppet
class { 'docker':
  registry_mirror => 'http://testmirror.io'
}
```

### Exec

Within the context of a running container, the docker module supports arbitrary commands:

```puppet
docker::exec { 'cron_allow_root':
  detach       => true,
  container    => 'mycontainer',
  command      => '/bin/echo root >> /usr/lib/cron/cron.allow',
  onlyif       => 'running',
  tty          => true,
  env          => ['FOO=BAR', 'FOO2=BAR2'],
  unless       => 'grep root /usr/lib/cron/cron.allow 2>/dev/null',
  refreshonly  => true,
}
```

### Plugin

The module supports the installation of docker plugins:

```puppet
docker::plugin {'foo/fooplugin:latest':
  settings => ['VAR1=test','VAR2=value']
}
```

To disable an active plugin:

```puppet
docker::plugin {'foo/fooplugin:latest':
  enaled => false,
}
```

To remove an active plugin:

```puppet
docker::plugin {'foo/fooplugin:latest'
  ensure => 'absent',
  force_remove => true,
}
thub.com
```

## Reference

### Classes

#### Public classes

* docker
* docker::compose
* docker::images
* docker::networks
* docker::params
* docker::plugins
* docker::registry_auth
* docker::run_instance
* docker::services
* docker::systemd_reload
* docker::volumes

#### Private classes

* docker::repos
* docker::install
* docker::config
* docker::service

### Defined types

* docker::exec
* docker::image
* docker::plugin
* docker::registry
* docker:run
* docker::secrets
* docker::stack
* docker::swarm
* docker::system_user

### Types

* docker_compose: A type that represents a docker compose file.
* docker_network: A type that represents a docker network.
* docker_volume: A type that represents a docker volume.

### Parameters

The following parameters are available in the `docker_compose` type:

#### 'compose_files'

An array containing the docker compose file paths.

#### `scale`

A hash of the name of compose services and number of containers.

Values - Compose services: 'string' , containers: 'integer'.

#### `options`

Additional options to be passed directly to docker-compose.

#### `up_args`

Arguments to be passed directly to docker-compose up.

The following parameters are available in the `docker_network` type:

#### `name`

The name of the network'

#### `driver`

The network driver the network uses.

#### `subnet`

The subnet in CIDR format that represents a network segment.

#### `gateway`

An ipv6 or ipv4 gateway for the master subnet.

#### `ip_range`

The range of ip addresses used by the network.

#### `ipam_driver`

The  IP address management driver.

#### `aux_address`

Auxiliary ipv4 or ipv6 addresses used by the network driver

#### `options`

Additional options for the network driver.

#### `additional_flags`

Additional flags for the docker network create.

#### `id`

The ID of the network provided by Docker.

The following parameters are available in the `docker_volume` type:

#### `name`

The name of the volume.

#### `driver`

The volume driver used by the volume.

#### `options`

Additional options for the volume driver.

#### `mountpoint`

The location that the volume is mounted to.

#### Docker class parameters

#### `version`

The version of the package to install.

Defaults to `undefined`.

#### `ensure`

Passed to the docker package.

Defaults to `present`.

#### `prerequired_packages`

An array of packages that are required to support Docker.

#### `tcp_bind`

The tcp socket to bind to. The format is tcp://127.0.0.1:4243.

Defaults to `undefined`.

#### `tls_enable`

Specifies whether to enable TLS.

Values `'true','false'`.

Defaults to `false`.

#### `tls_verify`

Specifies whether to use TLS and verify the remote.

Values `'true','false'`.

Defaults to `true`.

#### `tls_cacert`

The directory for the TLS CA certificate.

Defaults to `'/etc/docker/ca.pem'`.

#### `tls_cert`

The directory for the TLS certificate file.

Defaults to `'/etc/docker/cert.pem'`.

#### `tls_key`

The directory for the TLS key file.

Defaults to `'/etc/docker/cert.key'`.

#### `ip_forward`

Specifies whether to enable IP forwarding on the Docker host.

Values `'true','false'`.

Defaults to `true`.

#### `iptables`

Specifies whether to enable Docker's addition of iptables rules.

Values `'true','false'`.

Defaults to `true`.

#### `ip_masq`

Specifies whether to enable IP masquerading for the bridge's IP range.

Values `'true','false'`.

Defaults to `true`.

#### `icc`

Enable the Docker unrestricted inter-container and the daemon host communication.

To disable, it requires `iptables=true`.

Defaults to undef. The default value for the Docker daemon is `true`.

#### `bip`

Specifies the Docker network bridge IP in CIDR notation.

Defaults to `undefined`.

#### `mtu`

Docker network MTU.

Defaults to `undefined`.

#### `bridge`

Attach containers to a pre-existing network bridge. To disable container networking, include `none`.

Defaults to `undefined`.

#### `fixed_cidr`

IPv4 subnet for fixed IPs 10.20.0.0/16.

Defaults to `undefined`.

#### `default_gateway`

IPv4 address for the container default gateway. This address must be part of the bridge subnet (which is defined by bridge).

Defaults to `undefined`.

#### `ipv6`
Enables ipv6 support for the docker daemon

Defaults to false

####  `ipv6_cidr`

IPv6 subnet for fixed IPs

Defaults to `undefined`

#### `default_gateway_ipv6`

IPv6 address of the container default gateway:

Defaults to `undefined`

#### `socket_bind`

The unix socket to bind to.

Defaults to `unix:///var/run/docker.sock.`

#### `log_level`

Sets the logging level.

Defaults to undef. If no value is specified, Docker defaults to `info`.

Valid values: `debug`, `info`, `warn`, `error`, and `fatal`.

#### `log_driver`

Sets the log driver.

Defaults to undef.

Docker default is `json-file`.

Valid values:

* `none`: disables logging for the container. Docker logs are not available with this driver.
* `json-file`: the default Docker logging driver that writes JSON messages to file.
* `syslog`: syslog logging driver that writes log messages to syslog.
* `journald`: journald logging driver that writes log messages to journald.
* `gelf`: Graylog Extended Log Format (GELF) logging driver that writes log messages to a GELF endpoint: Graylog or Logstash.
* `fluentd`: fluentd logging driver that writes log messages to fluentd (forward input).
* `splunk`: Splunk logging driver that writes log messages to Splunk (HTTP Event Collector).

#### `log_opt`

Define the log driver option.

Defaults to undef.

Valid values:

* `none`: undef
* `json-file`: max-size=[0-9+][k|m|g] max-file=[0-9+]
* `syslog`: syslog-address=[tcp|udp]://host:port, syslog-address=unix://path, syslog-facility=daemon|kern|user|mail|auth, syslog|lpr|news|uucp|cron, authpriv|ftp, local0|local1|local2|local3, local4|local5|local6|local7, syslog-tag="some_tag"
* `journald`: undef
* `gelf`: gelf-address=udp://host:port, gelf-tag="some_tag"
* `fluentd`: fluentd-address=host:port, fluentd-tag={{.ID}} - short container id (12 characters), {{.FullID}} - full container id, {{.Name}} - container name
* `splunk`: splunk-token=<splunk_http_event_collector_token>, splunk-url=https://your_splunk_instance:8088|

#### `selinux_enabled`

Specifies whether to enable selinux support. SELinux supports the BTRFS storage driver.

Valid values are `true`, `false`.

Defaults to `false`.

#### `use_upstream_package_source`

Specifies whether to use the upstream package source.

Valid values are `true`, `false`.

When you run your own package mirror, set the value to `false`.

#### `pin_upstream_package_source`

Specifies whether to use the pin upstream package source. This option relates to apt-based distributions.

Valid values are `true`, `false`.

Defaults to `true`.

Set to `false` to remove pinning on the upstream package repository. See also `apt_source_pin_level`.

#### `apt_source_pin_level`

The level to pin your source package repository to. This relates to an apt-based system (such as Debian, Ubuntu, etc). Include $use_upstream_package_source and set the value to `true`.

To disable pinning, set the value to `false`.

Defaults to `10`.

#### `package_source_location`

Specifies the location of the package source.

For Debian, the value defaults to `http://get.docker.com/ubuntu`.

#### `service_state`

Specifies whether to start the Docker daemon.

Defaults to `running`.

#### `service_enable`

Specifies whether the Docker daemon starts up at boot.

Valid values are `true`, `false`.

Defaults to `true`.

#### `manage_service`

Specifies whether the service should be managed.

Valid values are `true`, `false'.

Defaults to `true'.

#### `root_dir`

The custom root directory for the containers.

Defaults to `undefined`.

#### `dns`

The custom dns server address.

Defaults to `undefined`.

#### `dns_search`

The custom dns search domains.

Defaults to `undefined`.

#### `socket_group`

Group ownership of the unix control socket.

Default is `OS and package specific`.


#### `extra_parameters`

Extra parameters that should be passed to the Docker daemon.

Defaults to `undefined`.

#### `shell_values`

The array of shell values to pass into the init script config files.

#### `proxy`

Defines the `http_proxy and https_proxy env` variables in `/etc/sysconfig/docker` (redhat/centos) or `/etc/default/docker` (debian).

#### `no_proxy`

Sets the `no_proxy` variable in `/etc/sysconfig/docker` (redhat/centos) or `/etc/default/docker` (debian).

#### `storage_driver`

Defines the storage driver to use.

Default is undef: let docker choose the correct one.

Valid values: `aufs`, `devicemapper`, `btrfs`, `overlay`, `overlay2`, `vfs`, and `zfs`.

#### `dm_basesize`

The size to use when creating the base device, which limits the size of images and containers.

Default value is `10G`.

#### `dm_fs`

The filesystem to use for the base image (xfs or ext4).

Defaults to `ext4`.

#### `dm_mkfsarg`

Specifies extra mkfs arguments to be used when creating the base device.

#### `dm_mountopt`

Specifies extra mount options used when mounting the thin devices.

#### `dm_blocksize`

A custom blocksize for the thin pool.

Default blocksize is `64K`.

Do not change this parameter after the lvm devices initialize.

#### `dm_loopdatasize`

Specifies the size to use when creating the loopback file for the data device which is used for the thin pool.

Default size is `100G`.

#### `dm_loopmetadatasize`

Specifies the size to use when creating the loopback file for the metadata device which is used for the thin pool.

Default size is `2G`.

#### `dm_datadev`

This is deprecated. Use `dm_thinpooldev`.

A custom blockdevice to use for data for the thin pool.

#### `dm_metadatadev`

This is deprecated. Use `dm_thinpooldev`.

A custom blockdevice to use for metadata for the thin pool.

#### `dm_thinpooldev`

Specifies a custom block storage device to use for the thin pool.

#### `dm_use_deferred_removal`

Enables the use of deferred device removal if libdm and the kernel driver support the mechanism.

#### `dm_use_deferred_deletion`

Enables the use of deferred device deletion if libdm and the kernel driver support the mechanism.

#### `dm_blkdiscard`

Enables the use of blkdiscard when removing devicemapper devices.

Valid values are `true`, `false`.

Defaults to `false`.

#### `dm_override_udev_sync_check`

Specifies whether to disable the devicemapper backend synchronizing with the udev device manager for the Linux kernel.

Valid values are `true`, `false`.

Defaults to `true`.

#### `manage_package`

Specifies whether to install or define the docker package. This is useful if you want to use your own package.

Valid values are `true`, `false`.

Defaults to `true`.

#### `package_name`

Specifies the custom package name.

Default is set on a per system basis in `docker::params`.

#### `service_name`

Specifies the custom service name.

Default is set on a per system basis in `docker::params`.

#### `docker_command`

Specifies a custom docker command name.

Default is set on a per system basis in `docker::params`.

#### `daemon_subcommand`

Specifies a subcommand for running docker as daemon.

Default is set on a per system basis in `docker::params`.

#### `docker_users`

Specifies an array of users to add to the docker group.

Default is `empty`.

#### `docker_group`

Specifies a string for the docker group.

Default is `OS and package specific`.

#### `daemon_environment_files`

Specifies additional environment files to add to the `service-overrides.conf` file.

#### `repo_opt`

Specifies a string to pass as repository options. This is for RedHat.

#### `storage_devs`

A quoted, space-separated list of devices to be used.

#### `storage_vg`

The volume group to use for docker storage.

#### `storage_root_size`

The maximum size of the root filesystem.

#### `storage_data_size`

The desired size for the docker data LV.

#### `storage_min_data_size`

Specifies the minimum size of data volume, otherwise the pool creation fails.

#### `storage_chunk_size`

Controls the chunk size/block size of the thin pool.

#### `storage_growpart`

Enables resizing the partition table backing root volume group.

#### `storage_auto_extend_pool`

Enables automatic pool extension using lvm.

#### `storage_pool_autoextend_threshold`

Auto pool extension threshold (in % of pool size).

#### `storage_pool_autoextend_percent`

Extends the pool by the specified percentage when the threshold is passed.

For further explanation please refer to the[PE documentation](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html) or [Bolt documentation](https://puppet.com/docs/bolt/latest/bolt.html) on how to execute a task.

## Limitations

This module supports:

* Debian 8.0
* Debian 9.0
* Ubuntu 14.04
* Ubuntu 16.04
* Ubuntu 18.04
* Centos 7.0

## Development

If you would like to contribute to this module, see the guidelines in [CONTRIBUTING.MD](https://github.com/puppetlabs/puppetlabs-docker/blob/master/CONTRIBUTING.md).

